import { useEffect, useState } from 'react'

import type { Counters } from '@/types'
import csrfToken from '@/utils/csrfToken'
import { fetchJson } from '@/utils/fetchJson'

const ZERO_COUNTERS: Counters = {
  industryJobs: 0,
  marketOrders: 0,
  planetaryColonies: 0,
  walletBalance: 0
}

export function useCounters(isLoggedIn: boolean) {
  const [counters, setCounters] = useState<Counters>(ZERO_COUNTERS)

  const fetchCounters = (url: string, options?: RequestInit) => {
    fetchJson(url, { credentials: 'same-origin', ...options })
      .then(data => setCounters(data as Counters))
      .catch(err => { console.error(err) })
  }

  const syncCounters = () => {
    fetchCounters('/api/sync', {
      headers: { 'X-CSRF-Token': csrfToken() },
      method: 'POST'
    })
  }

  useEffect(() => {
    if (isLoggedIn)
      fetchCounters('/api/counts')
    else
      setCounters(ZERO_COUNTERS)
  }, [isLoggedIn])

  return { counters, syncCounters }
}
