function Dashboard({ session }) {
  return (
    <div>EVE Industrial — logged in as {session.user?.character_name}</div>
  )
}

export default Dashboard
