.386
    .model flat, stdcall
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;includem biblioteci, si declaram ce functii vrem sa importam
    includelib msvcrt.lib
    extern exit: proc
    extern malloc: proc
    extern memset: proc
    extern printf: proc
    extern scanf: proc
	
	
    includelib canvas.lib
    extern BeginDrawing: proc
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;declaram simbolul start ca public - de acolo incepe executia
    public start
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;sectiunile programului, date, respectiv cod
            .data
    ;aici declaram date
    window_title DB "Battleships", 0
    area_width EQU 540
    area_height EQU 480
    area DD 0
    reseted DD 0 
    counter DD 0 
	
    arg1 EQU 8
    arg2 EQU 12
    arg3 EQU 16
    arg4 EQU 20

    n DD 0 ;
    m DD 0 ;
	matrix DD 0
	gasite DD 0
    miss DD 0
    total DD 20
	total2 DD 20
	
    distX DD 0
    distY DD 0
    grid_x EQU 20
    grid_y EQU 50
    square_x DD 0
    square_y DD 0

    square_n DD 0
    square_m DD 0

    grid EQU 400

    

    verif DD 0
	
   battleship1 DD 20
    battleship1v2  DD 60
    battleship1v3 DD 100
    battleship1y DD 50

    battleship2 DD 180
    battleship2v1 DD 50
   battleship2v2 DD 90
   battleship2v3 DD 130
    battleship2v4 DD 170

    battleship3 DD 300
    battleship3v1 DD 130
    battleship3v2 DD 170
    battleship3v3 DD 210
    battleship3v4 DD 250

    battleship4 DD 20
    battleship4v1 DD 60
    battleship4v2 DD 170

    battleship5 DD 100
    battleship5v1 DD 140
    battleship5v2 DD 180
    battleship5v3 DD 250

    battleship6 DD 100
    battleship6v1 DD 140
    battleship6v2 DD 180
    battleship6v3 DD 220
    battleship6v5 DD 330

    symbol_width EQU 10
    symbol_height EQU 20
    include digits.inc
    include letters.inc

    format DB "%d %d", 0
    mesaj DB "Introuceti dimensiunea matricei n * m: ", 0
	

            .code
			
	
			
    make_text proc
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp+arg1] ; citim simbolul de afisat
    cmp eax, 'A'
    jl make_digit
    cmp eax, 'Z'
    jg make_digit
    sub eax, 'A'
    lea esi, letters
    jmp draw_text
    make_digit:
    cmp eax, '0'
    jl make_space
    cmp eax, '9'
    jg make_space
    sub eax, '0'
    lea esi, digits
    jmp draw_text
    make_space:
    mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
    lea esi, letters

    draw_text:
    mov ebx, symbol_width
    mul ebx
    mov ebx, symbol_height
    mul ebx
    add esi, eax
    mov ecx, symbol_height
    bucla_simbol_linii:
    mov edi, [ebp+arg2] ; pointer la matricea de pixeli
    mov eax, [ebp+arg4] ; pointer la coord y
    add eax, symbol_height
    sub eax, ecx
    mov ebx, area_width
    mul ebx
    add eax, [ebp+arg3] ; pointer la coord x
    shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
    add edi, eax
    push ecx
    mov ecx, symbol_width
    bucla_simbol_coloane:
    cmp byte ptr [esi], 1
    je simbol_pixel_alb
    cmp byte ptr [esi], 0
    je simbol_pixel_negru
    cmp byte ptr [esi], 2
    je simbol_pixel_kaki
    cmp byte ptr [esi], 3
    je simbol_pixel_rosu
    mov dword ptr [edi], 0
    jmp simbol_pixel_next
    simbol_pixel_alb:
    mov dword ptr [edi], 0FFFFFFh
    jmp simbol_pixel_next
    simbol_pixel_negru:
    mov dword ptr [edi], 0
    jmp simbol_pixel_next
    simbol_pixel_kaki:
    mov dword ptr [edi], 426122h
    jmp simbol_pixel_next
    simbol_pixel_rosu:
    mov dword ptr [edi], 0E51C1Ch
    jmp simbol_pixel_next
    simbol_pixel_next:
    inc esi
    add edi, 4
    loop bucla_simbol_coloane
    pop ecx
    loop bucla_simbol_linii
    popa
    mov esp, ebp
    pop ebp
    ret
    make_text endp

            ; un macro ca sa apelam mai usor desenarea simbolului
    make_text_macro macro symbol, drawArea, x, y
    push y
    push x
    push drawArea
    push symbol
    call make_text
    add esp, 16  
    endm

	;calculeaza adresa de inceput a patratului, itereaza prin fiecare linie si pixel al patratului, 
	;seteaza culorile corespunzatoare in memoria respectiva 
	;si se asigura ca toate liniile patratului sunt desenate.
    draw_rectangle macro square_x, square_y, square_height, square_length, color
    local loop_line, et    
    mov eax, square_y      
    mov ebx, area_width    
    mul ebx                ; Se inmulteste coordonata y cu latimea pentru a determina pozitia de inceput a patratului
    add eax, square_x      ; adaugam coordonata x pentru a finaliza calculul pozitiei de inceput
    shl eax, 2             ; inmultim rezultatul cu 4 pentru a converti in adresa de memorie (fiecare pixel ocupa 4 bytes)
    add eax, area          ; adaugam offset-ul zonei de desenare pentru a obtine adresa corecta
    mov ebx, square_height ; memoram in ebx inaltimea patratului
    et:
    mov ecx, square_length ; Se memoreaza in ecx lungimea liniei curente din patrat
    loop_line:
    mov dword ptr[eax], color ; Se scrie valoarea de culoare in memoria adresata de eax (seteaza pixelul)
    add eax, 4           ; Se adauga 4 la eax pentru a trece la urmatorul pixel pe linie
    loop loop_line       ; Se repeta pentru fiecare pixel de pe linie
    add eax, 4 * area_width ; Se adauga 4 * latimea zonei de desenare pentru a trece la linia urmatoare
    mov esi, square_length ; Se memoreaza in esi lungimea liniei patratului pentru a calcula offset-ul necesar
    shl esi, 2             ; Se inmulteste cu 4 pentru a converti in offset in octeti
    sub eax, esi           ; Se scade offset-ul pentru a trece la linia urmatoare a patratului
    dec ebx               ; Se decrementeaza inaltimea patratului
    cmp ebx, 0            ; Se compara cu 0 pentru a verifica daca s-au desenat toate liniile patratului
    jne et                ; Daca ebx nu este zero, se sare la "et" pentru a desena urmatoarea linie
    endm                  

	;calculează adresa de început a liniei orizontale/verticale,
	;iterează prin fiecare pixel al liniei și setează culorile corespunzătoare în memoria respectivă.
    line_horizontal macro x, y, len, color
    local bucla_line   
    mov eax, y         
    mov ebx, area_width 
    mul ebx            ; Se înmulțește coordonata y cu lățimea pentru a determina poziția de început a liniei orizontale
    add eax, x         ; Se adaugă coordonata x pentru a finaliza calculul poziției de început
    shl eax, 2         
    add eax, area      ; Se adaugă offset-ul zonei de desenare pentru a obține adresa corectă
    mov ecx, len       ; Se memorează în ecx lungimea liniei orizontale
    bucla_line:
    mov dword ptr[eax], color ;se setează pixelul
    add eax, 4               ; Se adaugă 4 la eax pentru a trece la următorul pixel pe linie
    loop bucla_line          
    endm                     

    line_vertical macro x, y, len, color
    local bucla_line   
    mov eax, y         
    mov ebx, area_width 
    mul ebx            ; Se înmulțește coordonata y cu lățimea pentru a determina poziția de început a liniei verticale
    add eax, x         ; Se adaugă coordonata x pentru a finaliza calculul poziției de început
    shl eax, 2         ; Se înmulțește rezultatul cu 4 pentru a converti în adresă de memorie (fiecare pixel ocupă 4 octeți)
    add eax, area      ; Se adaugă offset-ul zonei de desenare pentru a obține adresa corectă
    mov ecx, len       ; Se memorează în ecx lungimea liniei verticale
    bucla_line:
    mov dword ptr[eax], color ;se setează pixelul
    add eax, 4*area_width    ;4 * lățimea zonei de desenare pentru a trece la linia următoare
    loop bucla_line          
    endm                      

    grid_col macro n
    local eticheta     
    mov ecx, n         
    mov eax, grid      ; memoram adresa grid-ului în registrul eax
    div ecx            ;  valoarea grid/n = dimensiunea pătratelor
    mov square_n, eax ;punem dimensiunea pătratelor în square_n
    mov distX, eax     ; Se memorează distanța pe axa X între fiecare coloană în distX
    mov edi, grid_x    ; Se memorează coordonata de început pe axa X în registrul edi
    add edi, distX     ; Se adaugă distanța pe axa X pentru a obține următoarea coordonată pe axa X
    eticheta:
    push ecx           ; Se salvează valoarea lui ecx pe stivă
    line_vertical edi, grid_y, grid, 3C8AFFh ; desenam o linie verticală la coordonatele (edi, grid_y)
    add edi, distX     ; Se adaugă distanța pe axa X pentru a obține următoarea coordonată pe axa X
    pop ecx            
    loop eticheta      
    endm              

	grid_lin macro m
    local eticheta     
    mov ecx, m        
    mov eax, grid     
    div ecx            ; valoarea grid/m = dimensiunea pătratelor
    mov square_m, eax 
    mov distY, eax     
    mov edi, grid_y    
    add edi, distY     
    eticheta:
    push ecx           
    line_horizontal grid_x, edi, grid, 3C8AFFh 
    add edi, distY     
    pop ecx           
    loop eticheta      
    endm               

 
modify macro initial, replace
    mov edx, replace  
    mov initial, edx  
    endm              

	;iar macro-ul identificare verifică dacă coordonatele x și y se află în grilă și,
	;în caz afirmativ, calculează și desenează un dreptunghi folosind macro-ul draw_rectangle.
identificare macro x, y
    local exit, missed   

    mov eax, grid_x       
    cmp dword ptr x, eax  ; Se compară valoarea lui x cu grid_x
    jl exit               ; Dacă x < grid_x, se sare la eticheta exit
    add eax, grid         
    cmp dword ptr x, eax  ; Se compară valoarea lui x cu eax
    jg exit               ; Dacă x > eax, se sare la eticheta exit
    mov eax, grid_y       
    cmp dword ptr y, eax  ; Se compară valoarea lui y cu grid_y
    jl exit               ; Dacă y < grid_y, se sare la eticheta exit
    add eax, grid         
    cmp dword ptr y, eax  ; Se compară valoarea lui y cu eax
    jg exit               ; Dacă y > eax, se sare la eticheta exit

    mov eax, x            
    sub eax, grid_x       
    mov edx, 0            ; Se setează edx la 0 pentru a evita depășirea înmulțirii/diviziunii
    div distX             ; Se împarte valoarea din eax la distX pentru a obține square_x
    mov square_x, eax     ; Se memorează valoarea în square_x

    mov eax, distX       
    mul square_x          ; Se înmulțește eax cu square_x
    add eax, grid_x       ; Se adaugă grid_x la eax pentru a obține noua valoare a lui x
    mov x, eax            

    mov eax, y            
    sub eax, grid_y       
    mov edx, 0           
    div distY             
    mov square_y, eax    

    mov eax, distY        
    mul square_y          ; Se înmulțește eax cu square_y
    add eax, grid_y       ; Se adaugă grid_y la eax pentru a obține noua valoare a lui y
    mov y, eax            

    missed:
    draw_rectangle x, y, distY, distX, 04E41FFh  ; Se desenează un dreptunghi cu coordonatele și dimensiunile calculate
    inc miss            ; Se incrementează valoarea lui miss
    exit:
    endm                


    ; functia de desenare - se apeleaza la fiecare click
    ; sau la fiecare interval de 200ms in care nu s-a dat click
    ; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
            ; arg2 - x
    ; arg3 - y

    draw proc
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp+arg1]   ; Se memorează valoarea primului argument în registrul eax
    cmp eax, 1            ; Se compară valoarea cu 1
    jz evt_click          ; Dacă este egală, se sare la eticheta evt_click
    cmp eax, 2            ; Se compară valoarea cu 2
    jz evt_timer          ; Dacă este egală, se sare la eticheta evt_timer

    ; Codul pentru inițializarea ferestrei cu pixeli albi
    mov eax, area_width   
    mov ebx, area_height  
    mul ebx               
    shl eax, 2            ; Se multiplică eax cu 4 pentru a obține dimensiunea în bytes
    push eax              ; Se pune dimensiunea pe stivă
    push 0                ; Se pune valoarea 0 pe stivă pentru culoarea de fundal (alb)
    push area             ; Se pune adresa zonei de desenare pe stivă
    call memset           ; Se apelează funcția memset pentru a umple zona de desenare cu pixeli albi
    add esp, 12           

reset:
    mov gasite, 0         
    mov miss, 0 
	mov total2, 20
    draw_rectangle grid_x, grid_y, 400, 400, 028A0F0h   
    grid_col n            ; Se apelează macro-ul grid_col pentru a desena coloanele grilei
    grid_lin m            ; Se apelează macro-ul grid_lin pentru a desena liniile grilei
    draw_rectangle grid_x, grid_y, grid, 5, 3C8AFFh     ; Se desenează un dreptunghi la stânga grilei
    draw_rectangle grid_x, grid_y + grid, 5, grid, 3C8AFFh ; Se desenează un dreptunghi in josul grilei
    draw_rectangle grid_x + grid, grid_y, grid + 5, 5, 3C8AFFh ; Se desenează un dreptunghi la dreapta grilei
    draw_rectangle grid_x, grid_y, 5, grid, 3C8AFFh     ; Se desenează un dreptunghi in susul grilei

    jmp afisare_litere

   evt_click:
    mov eax, [ebp+arg3]; Obținem coordonata y din argumentul arg3
    mov ebx, area_width ; Înmulțim coordonata y cu lățimea zonei
    mul ebx
    add eax, [ebp+arg2] ; Adaugăm coordonata x la rezultatul înmulțirii anterioare
    shl eax, 2  
    add eax, area 
    cmp dword ptr [eax], 028A0F0h; Compară valoarea de 32 de biți de la adresa calculată cu 028A0F0h
    jne evt_timer

    modify verif, 0
	
   battleship1_click:
    
    mov eax, [ebp+arg2]; Obține coordonata x din argumentul arg2
    cmp eax, battleship1 ; Compară coordonata x cu battleship1
    jl battleship1_fail; Sari la eticheta battleship1_fail dacă coordonata x este mai mică decât battleship1
    sub eax, square_n; Scade square_n din coordonata x
    cmp eax, battleship1; Compară coordonata x cu battleship1 după scăderea square_n
    jg battleship1_fail ; Sari la eticheta battleship1_fail dacă coordonata x este mai mare decât battleship1
    ; Obține coordonata y din argumentul arg3
    mov eax, [ebp+arg3]
    cmp eax, battleship1y; Compară coordonata y cu battleship1y
    jl battleship1_fail  ; Sari la eticheta battleship1_fail dacă coordonata y este mai mică decât battleship1y
    sub eax, square_m; Scade square_m din coordonata y
    cmp eax, battleship1y; Compară coordonata y cu battleship1y după scăderea square_m
    jg battleship1_fail ; Sari la eticheta battleship1_fail dacă coordonata y este mai mare decât battleship1y
    draw_rectangle battleship1, battleship1y, square_m, square_n, 0FF0000h; Desenează un dreptunghi utilizând coordonatele battleship1 și battleship1y,; dimensiunile square_m și square_n și culoarea 0FF0000h (roșu)
    modify verif, 1; Modifică valoarea variabilei verif la 1
    inc gasite
    dec total2
    
	battleship1_fail:
    mov counter, 0


    battleship1v2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship1v2
    jl battleship1v2_fail
    sub eax, square_n
    cmp eax, battleship1v2
    jg battleship1v2_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship1y
    jl battleship1v2_fail
    sub eax, square_m
    cmp eax, battleship1y
    jg battleship1v2_fail
    draw_rectangle battleship1v2, battleship1y, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	

    battleship1v2_fail:
    mov counter, 0

    battleship1v3_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship1v3
    jl battleship1v3_fail
    sub eax, square_n
    cmp eax, battleship1v3
    jg battleship1v3_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship1y
    jl battleship1v3_fail
    sub eax, square_m
    cmp eax, battleship1y
    jg battleship1v3_fail
    draw_rectangle battleship1v3, battleship1y, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2

    battleship1v3_fail:
    mov counter, 0

    battleship2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship2
    jl battleship2_fail
    sub eax, square_n
    cmp eax, battleship2
    jg battleship2_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship2v1
    jl battleship2_fail
    sub eax, square_m
    cmp eax, battleship2v1
    jg battleship2_fail
    draw_rectangle battleship2, battleship2v1, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship2_fail:
    mov counter, 0

    battleship2v2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship2
    jl battleship2v1_fail
    sub eax, square_n
    cmp eax, battleship2
    jg battleship2v1_fail
    mov eax, [ebp+arg3]
    cmp eax,battleship2v2
    jl battleship2v1_fail
    sub eax, square_m
    cmp eax,battleship2v2
    jg battleship2v1_fail
    draw_rectangle battleship2,battleship2v2, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship2v1_fail:
    mov counter, 0

    battleship2v3_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship2
    jl battleship2v2_fail
    sub eax, square_n
    cmp eax, battleship2
    jg battleship2v2_fail
    mov eax, [ebp+arg3]
    cmp eax,battleship2v3
    jl battleship2v2_fail
    sub eax, square_m
    cmp eax,battleship2v3
    jg battleship2v2_fail
    draw_rectangle battleship2,battleship2v3, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship2v2_fail:
    mov counter, 0

    battleship2v4_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship2
    jl battleship2v3_fail
    sub eax, square_n
    cmp eax, battleship2
    jg battleship2v3_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship2v4
    jl battleship2v3_fail
    sub eax, square_m
    cmp eax, battleship2v4
    jg battleship2v3_fail
    draw_rectangle battleship2, battleship2v4, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship2v3_fail:
    mov counter, 0

    battleship3_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship3
    jl battleship3_fail
    sub eax, square_n
    cmp eax, battleship3
    jg battleship3_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship3v1
    jl battleship3_fail
    sub eax, square_m
    cmp eax, battleship3v1
    jg battleship3_fail
    draw_rectangle battleship3, battleship3v1, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship3_fail:
    mov counter, 0

    battleship3v1_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship3
    jl battleship3v1_fail
    sub eax, square_n
    cmp eax, battleship3
    jg battleship3v1_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship3v2
    jl battleship3v1_fail
    sub eax, square_m
    cmp eax, battleship3v2
    jg battleship3v1_fail
    draw_rectangle battleship3, battleship3v2, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship3v1_fail:
    mov counter, 0

    battleship3v2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship3
    jl battleship3v2_fail
    sub eax, square_n
    cmp eax, battleship3
    jg battleship3v2_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship3v3
    jl battleship3v2_fail
    sub eax, square_m
    cmp eax, battleship3v3
    jg battleship3v2_fail
    draw_rectangle battleship3, battleship3v3, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship3v2_fail:
    mov counter, 0

    battleship3v3_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship3
    jl battleship3v3_fail
    sub eax, square_n
    cmp eax, battleship3
    jg battleship3v3_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship3v4
    jl battleship3v3_fail
    sub eax, square_m
    cmp eax, battleship3v4
    jg battleship3v3_fail
    draw_rectangle battleship3, battleship3v4, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship3v3_fail:
    mov counter, 0

    battleship4_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship4
    jl battleship4_fail
    sub eax, square_n
    cmp eax, battleship4
    jg battleship4_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship4v2
    jl battleship4_fail
    sub eax, square_m
    cmp eax, battleship4v2
    jg battleship4_fail
    draw_rectangle battleship4, battleship4v2, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship4_fail:
    mov counter, 0

    battleship4v1_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship4v1
    jl battleship4v1_fail
    sub eax, square_n
    cmp eax, battleship4v1
    jg battleship4v1_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship4v2
    jl battleship4v1_fail
    sub eax, square_m
    cmp eax, battleship4v2
    jg battleship4v1_fail
    draw_rectangle battleship4v1, battleship4v2, square_m, square_n, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship4v1_fail:
    mov counter, 0

    battleship5_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship5
    jl battleship5_fail
    sub eax, square_n
    cmp eax, battleship5
    jg battleship5_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship5v3
    jl battleship5_fail
    sub eax, square_m
    cmp eax, battleship5v3
    jg battleship5_fail
    draw_rectangle battleship5, battleship5v3, square_m, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship5_fail:
    mov counter, 0

    battleship5v1_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship5v1
    jl battleship5v1_fail
    sub eax, square_n
    cmp eax, battleship5v1
    jg battleship5v1_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship5v3
    jl battleship5v1_fail
    sub eax, square_m
    cmp eax, battleship5v3
    jg battleship5v1_fail
    draw_rectangle battleship5v1, battleship5v3, square_m, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship5v1_fail:
    mov counter, 0

    battleship5v2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship5v2
    jl battleship5v2_fail
    sub eax, square_n
    cmp eax, battleship5v2
    jg battleship5v2_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship5v3
    jl battleship5v2_fail
    sub eax, square_m
    cmp eax, battleship5v3
    jg battleship5v2_fail
    draw_rectangle battleship5v2, battleship5v3, square_m, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2
	
    battleship5v2_fail:
    mov counter, 0

    battleship6_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship6
    jl battleship6_fail
    sub eax, square_n
    cmp eax, battleship6
    jg battleship6_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship6v5
    jl battleship6_fail
    sub eax, square_m
    cmp eax, battleship6v5
    jg battleship6_fail
    draw_rectangle battleship6, battleship6v5, square_n, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2

    battleship6_fail:
    mov counter, 0

    battleship6v1_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship6v1
    jl battleship6v1_fail
    sub eax, square_n
    cmp eax, battleship6v1
    jg battleship6v1_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship6v5
    jl battleship6v1_fail
    sub eax, square_m
    cmp eax, battleship6v5
    jg battleship6v1_fail
    draw_rectangle battleship6v1, battleship6v5, square_n, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2

    battleship6v1_fail:
    mov counter, 0

    battleship6v2_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship6v2
    jl battleship6v2_fail
    sub eax, square_n
    cmp eax, battleship6v2
    jg battleship6v2_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship6v5
    jl battleship6v2_fail
    sub eax, square_m
    cmp eax, battleship6v5
    jg battleship6v2_fail
    draw_rectangle battleship6v2, battleship6v5, square_n, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2

    battleship6v2_fail:
    mov counter, 0

    battleship6v3_click:
    mov eax, [ebp+arg2]
    cmp eax, battleship6v3
    jl battleship6v3_fail
    sub eax, square_n
    cmp eax, battleship6v3
    jg battleship6v3_fail
    mov eax, [ebp+arg3]
    cmp eax, battleship6v5
    jl battleship6v3_fail
    sub eax, square_m
    cmp eax, battleship6v5
    jg battleship6v3_fail
    draw_rectangle battleship6v3, battleship6v5, square_n, square_m, 0FF0000h
    modify verif, 1
    inc gasite
	dec total2

    battleship6v3_fail:
    mov counter, 0

    cmp verif, 1
    je evt_timer
    identificare [ebp+arg2], [ebp+arg3]

    evt_timer:
    mov esi, total
    cmp gasite, esi
    jne afisare_litere
    inc reseted
    cmp reseted, 20
    je reset


    afisare_litere:
	;afisare mesaj win 
    mov esi, total
    cmp gasite, esi
    jne continuare
    draw_rectangle 100, 170, 160, 240, 0

    make_text_macro 'W', area, 210, 210
    make_text_macro 'I', area, 220, 210
    make_text_macro 'N', area, 230, 210


    continuare:
	;counter pentru lovituri 
    mov ebx, 10
    mov eax, gasite
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 505, 56
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 495, 56
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 485, 56

   ;counter pentru lovituri ratate
    mov ebx, 10
    mov eax, miss
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 505, 76
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 495, 76
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 485, 76

    ;counter pentru vaporase nedescoperite
    mov ebx, 10
    mov eax, total2
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 505, 96
	
    
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 495, 96
    mov edx, 0
    div ebx
    add edx, '0'
    make_text_macro edx, area, 485, 96
	
	


    ;scriem un mesaj

    make_text_macro 'B', area, 210, 20
    make_text_macro 'A', area, 220, 20
    make_text_macro 'T', area, 230, 20
    make_text_macro 'T', area, 240, 20
    make_text_macro 'L', area, 250, 20
    make_text_macro 'E', area, 260, 20
    make_text_macro 'S', area, 270, 20
    make_text_macro 'H', area, 280, 20
    make_text_macro 'I', area, 290, 20
    make_text_macro 'P', area, 300, 20
    make_text_macro 'S', area, 310, 20


    make_text_macro 'H', area, 435, 56
    make_text_macro 'I', area, 445, 56
    make_text_macro 'T', area, 455, 56
    make_text_macro ' ', area, 475, 56

    make_text_macro 'M', area, 435, 76
    make_text_macro 'I', area, 445, 76
    make_text_macro 'S', area, 455, 76
    make_text_macro 'S', area, 465, 76
    make_text_macro ' ', area, 475, 76
	

    make_text_macro 'L', area, 435, 96
    make_text_macro 'E', area, 445, 96
    make_text_macro 'F', area, 455, 96
    make_text_macro 'T', area, 465, 96
    make_text_macro ' ', area, 475, 96
	
	
	make_text_macro 'N', area, 405, 5
	make_text_macro 'E', area, 415, 5
	make_text_macro 'M', area, 425, 5
	make_text_macro 'T', area, 435, 5
	make_text_macro 'A', area, 445, 5
	make_text_macro 'N', area, 455, 5
	make_text_macro 'U', area, 465, 5
	
	make_text_macro 'A', area, 485, 5
	make_text_macro 'L', area, 495, 5
	make_text_macro 'E', area, 505, 5
	make_text_macro 'X', area, 515, 5


    final_draw:
    popa
    mov esp, ebp
    pop ebp
    ret
    draw endp
	
    start:
    push offset mesaj
    call printf
    push offset n
    push offset m
    push offset format
    call scanf

    mov eax, m
    mov ebx, n

    mul ebx
    shl eax, 2
    push eax
    call malloc
    add esp, 4
    mov matrix, eax
            ;alocam memorie pentru zona de desenat
    mov eax, area_width
    mov ebx, area_height
    mul ebx
    shl eax, 2
    push eax
    call malloc
    add esp, 4
    mov area, eax

    ;apelam functia de desenare a ferestrei
    ; typedef void (*DrawFunc)(int evt, int x, int y);
    ; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);

    push offset draw
    push area
    push area_height
    push area_width
    push offset window_title
    call BeginDrawing
    add esp, 20

    ;terminarea programului
    push 0
    call exit
    end start 