create or replace procedure crearViaje( 
    m_idRecorrido int, 
    m_idAutocar int, 
    m_fecha date, 
    m_conductor varchar
    ) is
    v_modelo_autocar int;
    v_plazas_disponibles int;

begin
    --verificar si el recorrido existe o no
    select count(*) into v_modelo_autocar from recorridos where idRecorrido = m_idRecorrido;
    if v_modelo_autocar = 0 then
        raise_application_error(-20001, 'recorridos inexistente');
    end if;

    --verificar si el autocar existe o no
    select count(*) into v_modelo_autocar from autocares where idAutocar = m_idAutocar;
    if v_modelo_autocar = 0 then
        raise_application_error(-20002, 'autocar_inexistente');
    end if;

    --verificar si el autocar esta ocupado en la fecha especificada
    select count(*) into v_plazas_disponibles
    from viajes
    where idAutocar = m_idAutocar and fecha = m_fecha;
    if v_plazas_disponibles > 0 then
        raise_application_error(-20003, 'autocar_ocupado');
    end if;

    -- Obtener el numero de plazas disponibles del autocar
    select NVL(m.nplazas, 25) into v_plazas_disponibles
    from autocares a
    left join modelos m on a.modelo = m.idModelo
    where a.idAutocar =  m_idAutocar;

    -- Insertar el nuevo viaje
    begin
        insert into viajes (idViaje, idAutocar, idRecorrido, fecha, nPlazasLibres, conductor)
        values ((select NVL(max(idViaje), 0) + 1 from viajes), m_idAutocar, m_idRecorrido, m_fecha, v_plazas_disponibles, m_conductor);
    exception
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20004, 'VIAJE_DUPLICADO');
    end;


    commit;
exception
    when no_data_found then
        raise_application_error(-20001, 'recorrido_inexistente');
    when others then
        rollback;
        raise;
end;
