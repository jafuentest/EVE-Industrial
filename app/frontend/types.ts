export interface SessionUser {
  id: number
  character_id: number
  character_name: string
  avatar: string
}

export interface Session {
  user: SessionUser
  add_character_url: string
}
