-- SET SERVEROUTPUT ON; 
-- declare
  -- type estadoJuego_curs is ref CURSOR return tree%ROWTYPE;
  -- est_Curs estadoJuego_curs;  
  -- juego tic_tac_toe:= tic_tac_toe(1);
  
  -- estado_act board_array;
  -- movin board_array;
  
  -- game_id number;
  -- result integer;
  -- posicion int;  
-- BEGIN
  -- movin:=board_array(null, null, null, null, null, null, null, null, null);
  -- game_id :=0;
  
  -- while(result <> 1) 
  -- loop
    -- --inicio juego
    -- posicion := '&posicion'; 
    -- movin(posicion):='x'; 
  
    -- --busca la jugada actual con el dato que se acaba de insertar
    -- OPEN est_Curs FOR
      -- select idRaiz, tablero
      -- from tree
      -- where idPadre=game_id;  
      
       -- IF (movin(1)=est_Curs.tablero(1) and movin(2)=est_Curs.tablero(2) and movin(3)=est_Curs.tablero(3) 
          -- and movin(4)=est_Curs.tablero(4) and movin(5)=est_Curs.tablero(5) and movin(6)=est_Curs.tablero(6)
          -- and movin(7)=estaest_Curs.tablerodo_act(7) and movin(8)=est_Curs.tablero(8) and movin(9)=est_Curs.tablero(9))
       -- THEN
        -- game_id= est_Curs.idRaiz;
       -- END IF;      
    -- CLOSE est_Curs;    
    -- movin:=play(movin IN board_array,result OUT integer,game_id IN OUT number);
  -- end loop;
  
-- END;

----------------------------------------------------------------
create or replace type tic_tac_toe as object (
  algo int,
  member function play(my_move IN board_array,result OUT integer,game_id IN OUT number) return board_array
);

create or replace function play(my_move IN board_array,result OUT integer,game_id IN OUT number) return board_array 

CREATE OR REPLACE TYPE BODY TIC_TAC_TOE AS
  member function play(my_move IN board_array,result OUT integer,game_id IN OUT number) return board_array AS
  tableroActual number;
  tableroEntrada board_array;
  tableroResp board_array;
  juego number;
  peso number;
  type estadoJuego_curs is ref CURSOR return tree%ROWTYPE;
  est_Curs estadoJuego_curs;  
  
  BEGIN    
    --busca la jugada actual con el dato que se acaba de insertar
    OPEN est_Curs FOR
      select idRaiz, tablero
      from tree
      where idPadre=game_id;  
      
       IF (my_move(1)=est_Curs.tablero(1) and my_move(2)=est_Curs.tablero(2) and my_move(3)=est_Curs.tablero(3) 
          and my_move(4)=est_Curs.tablero(4) and my_move(5)=est_Curs.tablero(5) and my_move(6)=est_Curs.tablero(6)
          and my_move(7)=estaest_Curs.tablerodo_act(7) and my_move(8)=est_Curs.tablero(8) and my_move(9)=est_Curs.tablero(9))
       THEN
        tableroActual := est_Curs.idRaiz;
       END IF;      
    CLOSE est_Curs;      
    
    select max(peso),idRaiz, tablero into peso, juego, tableroResp from tree where idPadre = tableroActual and rownum = 1 group by peso,idRaiz, tablero;
    --select max(peso),idRaiz from tree where idPadre = 0 group by peso,idRaiz
    game_id := juego;
    tableroResp := NULL;
    return tableroResp;          
  END play;
END;

drop type tic_tac_toe;
select * from tree where rownum <=14

  create or replace type board_array as varray(9) of char(1);

drop sequence idRaiz_seq;
drop table tree;
drop PROCEDURE GENERATE_TREE;

create sequence idRaiz_seq;

create table tree (
  idRaiz number primary key,
  idPadre number,  
  peso int,
  tablero board_array
);
create index indPadre on tree(idPadre);

----------------------------------------------------------------------------------------------------
--generar arbol
CREATE OR REPLACE PROCEDURE GENERATE_TREE(idRaiz number, idPadre  number, tableroR board_array)
IS 
 turno char(1);
 cant_x number;
 cant_o number;
 cant_n number;
 pos number;
 tableroH board_array;
 pesoN int;
 
BEGIN
  cant_x:=0;
  cant_o:=0;
  cant_n:=0; 
  pesoN:=0;
  FOR i IN 1..9
    LOOP
      IF tableroR(i)='x' THEN
         cant_x:=cant_x+1;       
     
      ELSIF tableroR(i)='o' THEN
         cant_o:=cant_o+1;       
      ELSE
         cant_n:=cant_n+1;      
      END IF;
  END LOOP;
    
    --escoge el turno
    turno:='x';
    IF cant_x > cant_o THEN
         turno:='o';             
    END IF;
    pos:=idRaiz;
        --llena los nuevo tableros
        FOR j IN 1..9
        LOOP
             
          IF tableroR(j) is null THEN                        
              tableroH:=board_array(null, null, null, null,null,null,null,null,null);
              FOR k IN 1..9
              LOOP
                tableroH(k):=tableroR(k);
              END LOOP;
              
              tableroH(j):= turno;                
              pos := idRaiz_seq.nextval;
              
              
              --verificar si hay un gane
              IF ((tableroH(1)=turno and tableroH(2)=turno and tableroH(3)=turno) or (tableroH(1)=turno and tableroH(5)=turno and tableroH(9)=turno) or 
               (tableroH(1)=turno and tableroH(4)=turno and tableroH(7)=turno) or (tableroH(2)=turno and tableroH(5)=turno and tableroH(8)=turno) or 
               (tableroH(3)=turno and tableroH(6)=turno and tableroH(9)=turno) or (tableroH(3)=turno and tableroH(5)=turno and tableroH(7)=turno) or
               (tableroH(4)=turno and tableroH(5)=turno and tableroH(6)=turno) or (tableroH(7)=turno and tableroH(8)=turno and tableroH(9)=turno))
               THEN 
               --hay jugada valida--> es una hoja
                pesoN:=1;  
                  IF turno='o'THEN
                    pesoN:=-1;
                  END IF;
               
               ELSIF(tableroH(1) is not  null and tableroH(2) is not null and tableroH(3) is not null and
                      tableroH(4) is not null and tableroH(5) is not null and tableroH(6) is not null and
                      tableroH(7) is not null and tableroH(8) is not null and tableroH(9) is not null) 
                      THEN
                      pesoN:=0;
               ELSE
                    GENERATE_TREE(pos, idRaiz, tableroH);
                    IF turno='o'THEN
                      select max(peso) into pesoN
                      from tree
                      where idPadre=pos
                      order by peso;
                    ELSE
                      select min(peso) into pesoN
                      from tree
                      where idPadre=pos
                      order by peso;
                    END IF;
                    
                       
              END IF;           
              insert into tree (idRaiz,idPadre,peso,tablero)
              values(pos,idRaiz,pesoN,tableroH);  
                     
          END IF;     
        END LOOP;
END GENERATE_TREE;

declare
  idRaiz number;
  idPadre number;
  tablero board_array;
BEGIN
  idRaiz:=0;
  idPadre :=null;
  tablero:=board_array(null, null, null, null,null,null,null,null,null);
  insert into tree values(0, null,0,tablero);
  GENERATE_TREE(idRaiz ,idPadre, tablero);
END;
---------------------------------------------------------------------------------

declare
tableroR board_array;
turno char;
idRaiz_A number;
pesoR int;
BEGIN
  tableroR:=board_array('x', 'o', 'x', 'o','x','o',null,null,null);
  turno:='x';
  idRaiz_A:=6;  
  obtenerPeso(tableroR,turno, idRaiz_A, pesoR);
  insert into numer values (pesoR);
END;
---------------------------------------------------------------
declare 
  tableroActual number;
  tableroResp board_array;
  juego number;
  peso number;
  tableroResp:=board_array('x', 'o', 'x', 'o','x','o',null,null,null);
  BEGIN
    select * into tableroActual from tree where idPadre = 0 and tablero(1) = 'x';    
END;


