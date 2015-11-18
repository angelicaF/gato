create or replace type tic_tac_toe as object (
  tab int, 
   member function play(my_move IN board_array, result OUT integer, game_id IN OUT number) return board_array
);


create or replace TYPE BODY TIC_TAC_TOE AS
  member function play(my_move IN board_array,result OUT integer,game_id IN OUT number) return board_array AS
  BEGIN
   
    
    
    RETURN NULL;
  END play;

END;

SET SERVEROUTPUT ON; 
declare
  type estadoJuego_curs is ref CURSOR return tree%ROWTYPE;
  est_Curs estadoJuego_curs;  
  juego tic_tac_toe:= tic_tac_toe(1);
  
  estado_act board_array;
  movin board_array;
  
  game_id number;
  result integer;
  posicion int;  
BEGIN
  movin:=board_array(null, null, null, null, null, null, null, null, null);
  game_id :=0;
  
  while(result <> 1) 
  loop
    --inicio juego
    posicion := '&posicion'; 
    movin(posicion):='x'; 
  
    --busca la jugada actual con el dato que se acaba de insertar
    OPEN est_Curs FOR
      select idRaiz, tablero
      from tree
      where idPadre=game_id;  
      
       IF (movin(1)=est_Curs.tablero(1) and movin(2)=est_Curs.tablero(2) and movin(3)=est_Curs.tablero(3) 
          and movin(4)=est_Curs.tablero(4) and movin(5)=est_Curs.tablero(5) and movin(6)=est_Curs.tablero(6)
          and movin(7)=estaest_Curs.tablerodo_act(7) and movin(8)=est_Curs.tablero(8) and movin(9)=est_Curs.tablero(9))
       THEN
        game_id= est_Curs.idRaiz;
       END IF;      
    CLOSE est_Curs;    
    movin:=play(movin IN board_array,result OUT integer,game_id IN OUT number);
  end loop;
  
END;




----------------------------------------------------------------
create or replace type tic_tac_toe as object (
  
  member function play(my_move IN board_array,result OUT integer,game_id IN OUT number := null) return board_array
);

CREATE OR REPLACE
TYPE BODY TIC_TAC_TOE AS

  member function play(my_move IN board_array,result OUT integer,game_id IN OUT number := null) return board_array AS
  BEGIN
    /* TODO implementation required */
    RETURN NULL;
  END play;

END;

drop type tic_tac_toe

create or replace type board_array as varray(9) of char(1);

drop sequence idRaiz_seq;
drop table tree;
drop PROCEDURE obtenerPeso;
drop PROCEDURE GENERATE_TREE;

create sequence idRaiz_seq;

create table tree (
  idRaiz number,
  idPadre number,
  tablero board_array,
  peso int
);

CREATE OR REPLACE PROCEDURE obtenerPeso(idRaiz_A in number, pesoR out int)
IS
BEGIN
  select max(peso) into pesoR
  from tree
  where idPadre=idRaiz_A
  order by peso; 
END obtenerPeso;


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
              insert into tree (idRaiz,idPadre, tablero, peso)
              values(pos,idRaiz, tableroH, pesoN);  
                     
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
  insert into tree values(0, null,tablero,0);
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




select * from numer
create table numer(
n board_array

);
drop table numer

insert into numer 
values(-1,3);

----------------------------------------------------------------
drop trigger idA_trig;
create or replace trigger idA_trig
before insert on tree
for each row
begin
    :new.idRaiz := idRaiz_seq.nextval;
    -- or if pre 11G:
    -- select ts_id_seq.nextval into :new.ts_id from dual;
end;

----------------------------------------------------------------

select *
from numer
where idPadre=1;

select *
from tree
where peso=0;


select max(peso) 
from tree
where idPadre=6
order by peso; 


  select max(c) into c
  from numer
  order  by c; 





