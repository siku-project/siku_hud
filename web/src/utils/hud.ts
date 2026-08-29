const WEATHER_ICONS: Record<string, string> = {
  clear: 'mdi-weather-sunny',
  extrasunny: 'mdi-weather-sunny',
  night: 'mdi-weather-night',
  cloudy: 'mdi-weather-cloudy',
  overcast: 'mdi-weather-cloudy',
  smog: 'mdi-weather-hazy',
  fog: 'mdi-weather-fog',
  rain: 'mdi-weather-pouring',
  drizzle: 'mdi-weather-rainy',
  thunder: 'mdi-weather-lightning-rainy',
  snow: 'mdi-weather-snowy',
  blizzard: 'mdi-weather-snowy-heavy',
  halloween: 'mdi-weather-night',
}

export const weatherIcon = (weather: string): string =>
  WEATHER_ICONS[weather] ?? 'mdi-weather-partly-cloudy'

export const clampPercent = (value: number): number => Math.min(100, Math.max(0, value))

const CARDINALS = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']

export const headingToCardinal = (heading: number): string => {
  const normalized = ((heading % 360) + 360) % 360
  return CARDINALS[Math.round(normalized / 45) % 8] as string
}
