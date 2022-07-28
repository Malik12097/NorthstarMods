global function ClGamemodeHotPotato_Init
global function ServerCallback_ShowHotPotatoCountdown
global function ServerCallback_AnnounceNewMark
global function ServerCallback_PassedHotPotato
global function ServerCallback_HotPotatoSpectator
global function ServerCallback_MarkedChanged

struct {
	var countdownRui
	var markedRui
	var mfdRui
	bool playingmusic
} file

void function ClGamemodeHotPotato_Init()
{
	// ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_lts.rpak" )
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_ffa.rpak" )

	file.markedRui = CreateCockpitRui( $"ui/overhead_icon_generic.rpak", 200 )
	RegisterSignal( "StopMusic" )
	file.playingmusic = false
	// file.mfdRui = CreatePermanentCockpitRui( $"ui/gamestate_info_mfd.rpak", MINIMAP_Z_BASE - 1 )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_fd_defeat_classic", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_mp_fd_defeat_classic", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "music_reclamation_17a_thingsgetbad", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_1, "music_reclamation_17a_thingsgetbad", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_2, "music_s2s_15_bossgone", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.GAMEMODE_2, "music_s2s_15_bossgone", TEAM_MILITIA )
}

void function ServerCallback_ShowHotPotatoCountdown( float endTime )
{
	file.countdownRui = CreateCockpitRui( $"ui/dropship_intro_countdown.rpak", 0 )
	RuiSetResolutionToScreenSize( file.countdownRui )
	RuiSetGameTime( file.countdownRui, "gameStartTime", endTime )
}

void function ServerCallback_AnnounceNewMark( int survivorEHandle )
{
    entity player = GetEntityFromEncodedEHandle( survivorEHandle )

	AnnouncementData announcement = Announcement_Create( Localize("#HOTPOTATO_NEWMARK", player.GetPlayerName() ) )
	Announcement_SetSubText( announcement, "#HOTPOTATO_RUN" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_PassedHotPotato()
{
	entity localPlayer = GetLocalClientPlayer()
	StartParticleEffectOnEntity( localPlayer.GetCockpit(), GetParticleSystemIndex( $"P_MFD" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	thread PlayMarkedSound( localPlayer )
	HideEventNotification()
	AnnouncementData announcement = Announcement_Create( "#HOTPOTATO_PASSED" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_HotPotatoSpectator()
{
    entity player = GetLocalClientPlayer()

	AnnouncementData announcement = Announcement_Create( "#HOTPOTATO_SPECTATING" )
	Announcement_SetSubText( announcement, "#HOTPOTATO_SPECTATINGDESC" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_MarkedChanged( int markedEHandle )
{
	thread MarkedChanged( markedEHandle )
}

void function MarkedChanged( int markedEHandle )
{
	WaitEndFrame()
	entity player = GetLocalViewPlayer()

	entity enemyMarked = GetEntityFromEncodedEHandle( markedEHandle )

	if ( IsAlive( enemyMarked ) )
	{
		if ( enemyMarked != player )
		{
			var rui = file.markedRui
			RuiSetBool( rui, "isVisible", true )
			RuiTrackFloat3( rui, "pos", enemyMarked, RUI_TRACK_OVERHEAD_FOLLOW )
			RuiSetBool( rui, "pinToEdge", false )
			//RuiTrackInt( rui, "teamRelation", enemyMarked, RUI_TRACK_TEAM_RELATION_VIEWPLAYER )
			//RuiSetBool( rui, "playerIsMarked", enemyMarked.IsPlayer() && GetLocalViewPlayer() == enemyMarked )
			//RuiSetBool( rui, "isMarked", enemyMarked.IsPlayer() )
			RuiSetImage( rui, "icon", $"rui/hud/gametype_icons/mfd/mfd_enemy" )

			/* rui = file.mfdRui
			RuiSetString( rui, "enemyMarkName", Localize( "#HOTPOTATO_RUN_FROM", enemyMarked.GetPlayerName() ) )
			RuiSetBool( rui, "isEnemyMarked", true ) */

			ClGameState_SetInfoStatusText( Localize( "#HOTPOTATO_SURVIVE" ) )
		}
		else
		{
			var rui = file.markedRui
			RuiSetBool( rui, "isVisible", false )

			/* rui = file.mfdRui
			RuiSetString( rui, "friendlyMarkName", Localize( "#HOTPOTATO_PASSTHEPOTATO" ) )
			RuiSetBool( rui, "isEnemyMarked", true ) */

			ClGameState_SetInfoStatusText( Localize( "#HOTPOTATO_SURVIVE" ) )
		}
		if( !file.playingmusic )
		{
			thread PlaySomeMusic( player )
			file.playingmusic = true
		}
	}
	else
	{

		var rui = file.markedRui
		RuiSetBool( rui, "isVisible", false )
		if (file.playingmusic)
		{
			player.Signal( "StopMusic" )
			file.playingmusic = false
		}

	}

	if ( !GamePlaying() )
		HideEventNotification()
}

void function PlaySomeMusic( entity player )
{
	player.EndSignal( "StopMusic" )

	if ( GetMusicReducedSetting() )
		return

	OnThreadEnd(
		function() : (  )
		{
			thread ForcePlayMusic( eMusicPieceID.GAMEMODE_2 , 3.2 ) 
		}
	)
	waitthread ForcePlayMusic( eMusicPieceID.GAMEMODE_1 ) 	//Is looping music, so doesn't return from this until the end signals kick in
	player.WaitSignal( "StopMusic" )
}

void function PlayMarkedSound( entity player )
{
	EmitSoundOnEntity( player, "UI_InGame_MarkedForDeath_PlayerMarked"  )
	wait 1.0
	StopSoundOnEntity( player, "UI_InGame_MarkedForDeath_PlayerMarked"  ) // this ui has a portion with a loud noise that would ruin music lol
}