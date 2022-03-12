import Config

config :logger, :console,
  format: {Stenotype.Output.Logger, :format},
  metadata: [:stenotype, :statement]
