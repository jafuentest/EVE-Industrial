function camelizeKeys(obj: unknown): unknown {
  if (Array.isArray(obj))
    return obj.map(camelizeKeys)

  if (obj && typeof obj === 'object') {
    return Object.fromEntries(
      Object.entries(obj as Record<string, unknown>).map(([k, v]) => [
        k.replace(/_([a-z])/g, (_, c) => c.toUpperCase()),
        camelizeKeys(v),
      ])
    )
  }

  return obj
}

export default camelizeKeys
