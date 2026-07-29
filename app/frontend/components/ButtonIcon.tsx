import type { ButtonHTMLAttributes } from 'react'

import styles from './ButtonIcon.module.css'

interface ButtonIconProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'className'> {
  'aria-label': string
}

function ButtonIcon({ children, ...props }: ButtonIconProps) {
  return (
    <button className={styles.button} {...props}>
      {children}
    </button>
  )
}

export default ButtonIcon
