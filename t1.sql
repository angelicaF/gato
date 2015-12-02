-- SET SERVEROUTPUT ON;

----------------------------------TABLAS Y TIPOS---------------------------------------------------------
create type board_array as varray(9) of char(1);  --tablero de juego "3x3"

create table tree (
  idRaiz number primary key,  --id del nodo
  idPadre number,             --id del nodo padre
  peso int,                   --peso: 1 gano, 0 empato, -1 pierdo
  tablero board_array         --tablero con la jugada correspondiente al nodo
);

create index indPadre on tree(idPadre); --Se crea un indice para optimizar las consultas
create sequence idRaiz_seq;       --Secuencia para :

-----------------------Se llena el arbol de juego con tablero y sus pesos-------------------------------------------
create or replace PROCEDURE generaArbol(idRaiz number, idPadre  number, tableroR board_array) is
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
      generaArbol(pos, idRaiz, tableroH);
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
    insert into tree (idRaiz,idPadre,peso,tablero) values(pos,idRaiz,pesoN,tableroH);  --Inserta en el arbol
    END IF;
  END LOOP;
END generaArbol;
--------------------------------------------------------------------------------------------------------------------------

---------------------------------------------FIRMAS------------------------------------------------------------
create or replace type tic_tac_toe as object (
  algo int,
  member procedure generate_tree,
  member function play(my_move IN board_array,res OUT integer,game_id IN OUT number) return board_array
);

---------------------------------------------------------------------------------------------------------------
-------------------------------------Funcion play--------------------------------------------------------------
create or replace
TYPE BODY TIC_TAC_TOE IS
  member function play(my_move IN board_array,res OUT integer,game_id IN OUT number) return board_array IS
  tableroActual number;
  miTablero number;
  tableroEntrada board_array;
  tableroResp board_array;
  vpeso number;
  iguales number;   -- 0 = diferente; 1 = iguales
  CURSOR estadoJuego_curs IS
  select idRaiz, tablero
  from tree
  where idPadre=game_id;

  BEGIN
  --busca la jugada actual con el dato que se acaba de insertar
    --create sequence idRaiz_seq;

    --Se recorren todos los hijos de la jugada anterior para buscar el tablero de la jugada entrante
    FOR est_Curs in estadoJuego_curs
    LOOP
      tableroEntrada := est_Curs.tablero;
      dbms_output.put_line('CURSOR ');
      dbms_output.put_line('('||tableroEntrada(1)||','||tableroEntrada(2)||','||tableroEntrada(3)||','||
      tableroEntrada(4)||','||tableroEntrada(5)||','||tableroEntrada(6)||','||tableroEntrada(7)||','||tableroEntrada(8)||','||tableroEntrada(9)||')');

      --Se debe revisar si el tablero tiene posiciones nulas antes de comparar caracteres, ya que no se puede comparar null = null
      iguales :=1;
      For i in 1..my_move.count loop
        if(my_move(i) is null)
        --Si uno es nulo y el otro no, no son iguales
        then
          if(tableroEntrada(i) is not null)
          then
            iguales := 0;
          end if;
        else
        --Si encuentra dos caracteres diferentes en una misma posicion no son iguales se asume que los tableros son distintos
          if (tableroEntrada(i) != my_move(i))
          then
            iguales := 0;
          end if;
        end if;
      end loop;

      if (iguales = 1)
      then
        tableroActual := est_Curs.idRaiz;
      --else
          --no son iguales => ¿?
      end if;
      dbms_output.put_line('Tablero '||tableroActual);
    END LOOP;
    --tableroActual := 567266;
    select idRaiz, max(peso) into miTablero, vpeso from tree where idPadre = tableroActual and rownum = 1 group by idRaiz;
    select tablero into tableroResp from tree where idRaiz = miTablero;
    --select idRaiz, max(peso) from tree where idPadre = 0 and rownum = 1 group by idRaiz
    dbms_output.put_line('('||tableroResp(1)||','||tableroResp(2)||','||tableroResp(3)||','||
    tableroResp(4)||','||tableroResp(5)||','||tableroResp(6)||','||tableroResp(7)||','||tableroResp(8)||','||tableroResp(9)||')');
    game_id := miTablero;
  END play;
-----------------------------------Procedimiento generate_tree---------------------------------------------------------------------------
  MEMBER PROCEDURE generate_tree
  IS
  idRaiz number;
  idPadre number;
  tablero board_array;
  BEGIN
    idRaiz:=0;
    idPadre :=null;
    tablero:=board_array(null, null, null, null,null,null,null,null,null);
    insert into tree values(0, null,0,tablero);
    generaArbol(idRaiz ,idPadre, tablero);
  END generate_tree;
END;
--------------------------------------FIN BODY TIC_TAC_TOE---------------------------------------------------------------

declare
tic TIC_TAC_TOE;
tableroE board_array;
tableroR board_array;
idRaiz_A number;
game_id number;
res int;
pesoR int;
BEGIN
--delete from tree;
tic := TIC_TAC_TOE(1);
--tic.generate_tree;
game_id := 0;
res := 0;
tableroE:=board_array('x', null,null,null,null,null,null,null,null);
tableroR := tic.play(board_array('x', null,null,null,null,null,null,null,null),res,game_id);
dbms_output.put_line(tableroR(1)||tableroR(2)||tableroR(3));
END;
---------------------------------------------------------------
--declare
