interface ProfileImageProps {
  size: number
  characterId: number
}

function ProfileImage({ size, characterId }: ProfileImageProps) {
  const url = `https://images.evetech.net/characters/${characterId}/portrait?size=${size}`

  return (
    <img src={url} width={size} height={size} alt="Character portrait" />
  )
}

export default ProfileImage
