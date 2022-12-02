.include "../include/bank_ids.inc"

.segment "ROM_8"	; Страница данных 
	.byte BANK_TILEMAPS_01	; номер страницы
Tilemap_Table1:

	.WORD Tilemap_Copyright
	.WORD Tilemap_Cutscene_01
	.WORD Tilemap_Cutscene_02
	.WORD Tilemap_Cutscene_03
	.WORD Tilemap_Cutscene_04	
	.WORD Tilemap_Title_Logo	
	.WORD Tilemap_SaveScreen	

Tilemap_Copyright:
  .include "../../data/tilemaps/interface/copyright.asm"
Tilemap_Cutscene_01:
  .include "../../data/tilemaps/cutscene/cutscene_01.asm"
Tilemap_Cutscene_02:
  .include "../../data/tilemaps/cutscene/cutscene_02.asm"
Tilemap_Cutscene_03:
  .include "../../data/tilemaps/cutscene/cutscene_03.asm" 
Tilemap_Cutscene_04:
  .include "../../data/tilemaps/cutscene/cutscene_04.asm" 
Tilemap_Title_Logo:
  .include "../../data/tilemaps/interface/title_logo.asm"   
Tilemap_SaveScreen:
  .include "../../data/tilemaps/interface/save_screen.asm" 

.global Tilemap_Table1

