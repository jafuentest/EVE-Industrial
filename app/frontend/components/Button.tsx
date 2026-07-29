import clsx from 'clsx'
import type { ButtonHTMLAttributes } from 'react'

import styles from './Button.module.css'

interface ButtonProps extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, 'className'> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}

function Button({ children, variant = 'secondary', size = 'sm', ...props }: ButtonProps) {
  return (
    <button className={clsx(styles.button, styles[variant], styles[size])} {...props}>
      {children}
    </button>
  )
}

export default Button
