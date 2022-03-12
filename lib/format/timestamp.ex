defmodule Stenotype.Format.Timestamp do
  def fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 2}),
         time <- NaiveDateTime.to_time(timestamp),
         month_str <- String.pad_leading("#{timestamp.month}", 2, "0"),
         day_str <- String.pad_leading("#{timestamp.day}", 2, "0") do
      "#{month_str}/#{day_str}|#{Time.to_iso8601(time)}"
    end
  end
end
