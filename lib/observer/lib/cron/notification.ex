defmodule Observer.Cron.Notification do
  use GenServer

  require Logger

  alias Behold.Models.{Check, Alert}
  alias Observer.Notification.{Email, SMS}

  @email_module Application.get_env(:behold, :email_module, Email)
  @negative_states [:warning, "warning", :critical, "critical"]
  @positive_states [:nominal, "nominal"]
  
  def start_link(%{id: id} = check) do
    GenServer.start_link(
      __MODULE__,
      check,
      name: String.to_atom("#{id}-notification")
    )
  end

  def init(check) do
    Logger.debug("#{__MODULE__}: Initiailizing gen server for notification on check #{check.id} with interval")
    Process.send_after(self(), :notification, 1_000)
    {:ok, %{check: check}}
  end

  def handle_info(:notification, %{check: %{interval: interval, id: id}} = check) do
    Logger.debug("#{__MODULE__}: Running notification logic on check #{id}")
    {:ok, updated_check} = Check.get_by_id(id)
    do_notification(Map.from_struct(updated_check))
    Process.send_after(self(), :notification, interval)
    {:noreply, %{check: Map.from_struct(updated_check)}}
  end

  def do_notification(%{} = check) do
    {:ok, alerts} = Alert.get_all_valid_alerts(check.id)
    alerts
    |> Enum.map(fn alert ->
      possibly_send_notification(alert, check)
    end)
  end

  def possibly_send_notification(alert, check) do
    if state_has_changed?(check) do
      {:ok, type} = determine_type_to_send(check)
      send_notification(type, check, alert) 
    else
      Logger.debug("#{__MODULE__}: State didn't change for check #{check.id} - no notifciation sending")
    end
  end

  def state_has_changed?(%{state: current_state, last_alerted_for: last_state} = _check) do
    current_state != last_state
  end

  def determine_type_to_send(%{state: current_state, last_alerted_for: last_state} = check) do
    case {get_sentiment(current_state), get_sentiment(last_state)} do
      {:negative, :positive} -> {:ok, :down}
      {:positive, :negative} -> {:ok, :recovery}
      {:negative, :negative} -> {:ok, :noop}
      {:positive, :positive} -> {:ok, :noop}
      {:positive, :unset} -> {:ok, :noop}
      {:negative, :unset} -> {:ok, :down}
      {:unknown, _} -> {:ok, :noop}
      {_, :unknown} -> {:ok, :noop}
    end
  end

  def get_sentiment(state) do
    if negative?(state) do
      :negative
    else
      if positive?(state) do
        :positive
      else
        if unset?(state) do
          :unset
        else
          :unknown
        end
      end
    end
  end

  def negative?(state) do
    Enum.member?(@negative_states, state)
  end

  def positive?(state) do
    Enum.member?(@positive_states, state)
  end

  def unset?(state) do
    if is_nil(state) or state == "" do
      true
    else
      false
    end
  end

  def send_notification(:down, check, alert) do
    case alert.type do
      :email ->
        Logger.info("#{__MODULE__}: Want to send :down notification for alert #{alert.id}")
        @email_module.send(check, alert, :down)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :critical)
      :sms ->
        SMS.send(check, alert, :down)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :critical)
      type ->
        Logger.error("#{__MODULE__}: Wanted to fire bad alert for check #{check.id} but alert type #{inspect(type)} unknown")
    end
  end
  
  def send_notification(:recovery, check, alert) do
    case alert.type do
      :email ->
        Logger.info("#{__MODULE__}: Want to send :recovery notification for alert #{alert.id}")
        @email_module.send(check, alert, :up)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :nominal) 
      :sms ->
        SMS.send(check, alert, :up)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :nominal)
      type ->
        Logger.error("#{__MODULE__}: Wanted to fire good alert for check #{check.id} but alert type #{inspect(type)} unknown") 
    end
  end

  def send_notification(:noop, check, alert) do
    Logger.warn("#{__MODULE__}: Somehow got to here as a noop for check #{check.id} and alert #{alert.id}")
  end
end