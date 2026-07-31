import logoWordmark from '@/assets/logo-wordmark.svg'

import styles from './Brand.module.css'

function Brand() {
  return (
    <img className={styles.brandImg} src={logoWordmark} alt="EVE Industrial" />
  )
}

export default Brand
