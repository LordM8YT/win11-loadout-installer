function Get-LoadoutProfiles {
    return @(
        [pscustomobject]@{
            Key = "Competitive"
            Label = "Competitive"
            Description = "FPS-first, lower background noise, cleaner desktop."
        },
        [pscustomobject]@{
            Key = "FiveM"
            Label = "FiveM"
            Description = "Roleplay-oriented setup with Discord and cyber styling."
        },
        [pscustomobject]@{
            Key = "Streamer"
            Label = "Streamer"
            Description = "Gaming plus streaming and creator-friendly defaults."
        },
        [pscustomobject]@{
            Key = "Creator"
            Label = "Creator"
            Description = "Balanced profile for gaming, coding, and media."
        }
    )
}

