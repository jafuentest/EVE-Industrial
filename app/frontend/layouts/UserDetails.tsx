import { LogOut } from 'lucide-react'

import ButtonIcon from '@/components/ButtonIcon'
import ProfileImage from '@/components/ProfileImage'
import { useLogout, useRequiredSession } from '@/contexts/AuthContext'

import styles from './UserDetails.module.css'

function UserDetails() {
  const session = useRequiredSession()
  const logout = useLogout()

  return (
    <div className={styles.userInfo}>
      <span className={styles.profileImageContainer}>
        <ProfileImage size={32} characterId={session.user.characterId} />
      </span>
      <span className={styles.userCorpNames}>
        <span className={styles.username}>{session.user.characterName}</span>
        <span className={styles.corporation}>{session.user.corporationName}</span>
      </span>
      <ButtonIcon aria-label="Log out" onClick={logout}>
        <LogOut size={16} />
      </ButtonIcon>
    </div>
  )
}

export default UserDetails
