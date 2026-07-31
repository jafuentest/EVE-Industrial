function formatIsk(amount: number): string {
  const magnitude = Math.abs(amount)

  if (magnitude >= 1e9) return `${(amount / 1e9).toFixed(2)}B`
  if (magnitude >= 1e6) return `${(amount / 1e6).toFixed(2)}M`
  if (magnitude >= 1e3) return `${(amount / 1e3).toFixed(2)}K`
  return amount.toFixed(2)
}

export default formatIsk
