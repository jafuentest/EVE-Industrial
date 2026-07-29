export interface SessionUser {
  id: number
  characterId: number
  characterName: string
  corporationName: string
  avatar: string
}

export interface Session {
  user: SessionUser
  addCharacterUrl: string
}

export interface Counters {
  industryJobs: number
  marketOrders: number
  planetaryColonies: number
  walletBalance: number
}
