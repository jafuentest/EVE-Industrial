import type { ComponentType } from 'react'
import { Link, useMatch } from 'react-router-dom'

import clsx from 'clsx'

import styles from './NavItem.module.css'

interface NavItemProps {
  path: string
  label: string
  icon: ComponentType
  counter: number
}

function NavItem({ path, label, icon: Icon, counter }: NavItemProps) {
  const isActive = useMatch(path) !== null

  return (
    <li className={clsx(styles.navItem, { [styles.active]: isActive })}>
      <Link to={path} className={styles.link}>
        <span className={clsx(styles.indicator, { [styles.active]: isActive })}/>
        <span className={styles.icon}>
          <Icon />
        </span>
        <span className={styles.label}>{label}</span>
        {counter > 0 && <span className={styles.count}>{counter}</span>}
      </Link>
    </li>
  )
}

export default NavItem
