defmodule ValueType do
  use EctoEnum, type: :value_type, enums: [:nominal, :warning, :critical]
end
