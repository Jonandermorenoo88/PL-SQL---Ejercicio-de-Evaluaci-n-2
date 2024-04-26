create or replace procedure crearViaje( 
    m_idRecorrido int, 
    m_idAutocar int, 
    m_fecha date, 
    m_conductor varchar
    ) is
    v_modelo_autocar int; --variable para almacenar el resultado de las consultas
    v_plazas_disponibles int; -- variable para almacenar el numero de plazas disponibles

begin
    --verificar si el recorrido existe o no
    select count(*) into v_modelo_autocar from recorridos where idRecorrido = m_idRecorrido;
    if v_modelo_autocar = 0 then -- si no encuentra el recorrido
        raise_application_error(-20001, 'recorridos inexistente'); --por lo tanto genera un error
    end if; --cerramos el if
--------------------------------------------------------------------------------------------------
    --verificar si el autocar existe o no
    select count(*) into v_modelo_autocar from autocares where idAutocar = m_idAutocar;
    if v_modelo_autocar = 0 then --si no se encuentra el autocar
        raise_application_error(-20002, 'autocar_inexistente'); --entonces generamos un error
    end if; --cerramos el if
-------------------------------------------------------------------------------------------------
    --verificar si el autocar esta ocupado en la fecha especificada
    select count(*) into v_plazas_disponibles
    from viajes
    where idAutocar = m_idAutocar and fecha = m_fecha;
    if v_plazas_disponibles > 0 then --si el autocar esta ocupado
        raise_application_error(-20003, 'autocar_ocupado'); --por lo tanto generamos el error
    end if; -- cerramos el if
--------------------------------------------------------------------------------------------------
    -- Obtener el numero de plazas disponibles del autocar
    --NVL se utiliza para remplazar un valor nulo a otro especifico.
    select NVL(m.nplazas, 25) into v_plazas_disponibles --seleccionamos el numero de plazas del autocar
    from autocares a
    left join modelos m on a.modelo = m.idModelo --unimos las tablas de autocales con las de modelos ya que tienen relacion
    where a.idAutocar =  m_idAutocar; --condicion para el autocar especifico
-------------------------------------------------------------------------------------------------
    -- Insertar el nuevo viaje
    begin
        insert into viajes (idViaje, idAutocar, idRecorrido, fecha, nPlazasLibres, conductor)
        values ((select NVL(max(idViaje), 0) + 1 from viajes), m_idAutocar, m_idRecorrido, m_fecha, v_plazas_disponibles, m_conductor);
    exception
        WHEN DUP_VAL_ON_INDEX THEN --si hay un intento de insertar un viaje duplicado
            RAISE_APPLICATION_ERROR(-20004, 'viaje_duplicado'); --genera un error de viaje duplicado
    end;

    commit; --hacemos una confirmacion de la transaccion despues de la inserccion del nuevo viaje
exception
    when no_data_found then --si aqui no se encuentra el recorrido especifico
        raise_application_error(-20001, 'recorrido_inexistente'); --genera un error
    when others then
        rollback; --aqui si por ejemplo ocurre otro tipo de error que desaga los cambios
        raise; --lanza una expecion para mostrar el error
end;
