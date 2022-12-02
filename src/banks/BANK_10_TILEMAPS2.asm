.include "../include/bank_ids.inc"

.segment "ROM_10"	; Страница данных 
	.byte BANK_TILEMAPS_02	; номер страницы
Tilemap_Table2:
	.WORD Tilemap_Difficulty
	.WORD Tilemap_Env2_1
	.WORD Tilemap_Env2_2
	.WORD Tilemap_Env2_3
	.WORD Tilemap_Env2_4

Tilemap_Difficulty:
  .include "../../data/tilemaps/interface/difficulty.asm" 
Tilemap_Env2_1:
  .include "../../data/tilemaps/environment/environment_1_1.asm" 
Tilemap_Env2_2:
  .include "../../data/tilemaps/environment/environment_1_2.asm" 
Tilemap_Env2_3:
  .include "../../data/tilemaps/environment/environment_1_3.asm" 
Tilemap_Env2_4:
  .include "../../data/tilemaps/environment/environment_1_4.asm" 



  
.global Tilemap_Table2

