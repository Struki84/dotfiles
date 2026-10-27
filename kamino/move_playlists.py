from plexapi.myplex import MyPlexAccount
from plexapi.server import PlexServer

PLEX_ACCOUNT_TOKEN = ""
OLD_SERVER_NAME = ""
NEW_SERVER_URL = ""
NEW_MUSIC_LIBRARY = ""

plex_account = MyPlexAccount(token=PLEX_ACCOUNT_TOKEN)
print("Your servers:", [resource.name for resource in plex_account.resources()])

old_server = plex_account.resource(OLD_SERVER_NAME).connect()
new_server = PlexServer(NEW_SERVER_URL, PLEX_ACCOUNT_TOKEN)
new_music_library = new_server.library.section(NEW_MUSIC_LIBRARY)
existing_playlist_titles = {playlist.title for playlist in new_server.playlists()}


def find_matching_track(old_track):
    candidates = new_music_library.searchTracks(title=old_track.title)
    for candidate in candidates:
        same_artist = candidate.grandparentTitle == old_track.grandparentTitle
        same_album = candidate.parentTitle == old_track.parentTitle
        if same_artist and same_album:
            return candidate
    for candidate in candidates:
        if candidate.grandparentTitle == old_track.grandparentTitle:
            return candidate
    return None


for old_playlist in old_server.playlists(playlistType="audio"):
    if old_playlist.smart:
        print(f"SKIP (smart playlist, recreate by hand): {old_playlist.title}")
        continue
    if old_playlist.title in existing_playlist_titles:
        print(f"SKIP (already exists on kamino): {old_playlist.title}")
        continue

    matched_tracks = []
    missing_tracks = []
    for old_track in old_playlist.items():
        new_track = find_matching_track(old_track)
        if new_track:
            matched_tracks.append(new_track)
        else:
            missing_tracks.append(f"{old_track.grandparentTitle} - {old_track.title}")

    if matched_tracks:
        new_server.createPlaylist(old_playlist.title, items=matched_tracks)

    print(
        f"DONE: {old_playlist.title} ({len(matched_tracks)} copied, {len(missing_tracks)} missing)"
    )
    for missing_track in missing_tracks:
        print(f"    missing: {missing_track}")
