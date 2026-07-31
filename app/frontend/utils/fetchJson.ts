import camelize from "./camelize"

export async function fetchJson<T>(url: string, options?: RequestInit): Promise<T> {
  const r = await fetch(url, options)
  if (!r.ok)
    throw new Error(`Failed to fetch ${url}: ${r.status} ${r.statusText}`)

  const contentType = r.headers.get('content-type')
  if (!contentType?.includes('application/json'))
    throw new Error(`Expected JSON from ${url}, got ${contentType}`)

  const data = await r.json()
  return camelize(data) as T
}

export async function fetchJsonWithStatus<T>(url: string, options?: RequestInit): Promise<{ data: T, status: number }> {
  const r = await fetch(url, options)
  const contentType = r.headers.get('content-type')

  if (!contentType?.includes('application/json'))
    throw new Error(`Expected JSON from ${url}, got ${contentType}`)

  const data = await r.json()
  return {
    data: camelize(data) as T,
    status: r.status
  }
}
