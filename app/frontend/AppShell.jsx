function AppShell({ children, session }) {
  return (
    <div>
      <header>
        <h1>EVE Industrial</h1>
        {session && <p>Logged in as {session.user?.character_name}</p>}
      </header>
      <main>{children}</main>
      <footer>
        &copy; {new Date().getFullYear()} EVE Industrial
      </footer>
    </div>
  )
}

export default AppShell
