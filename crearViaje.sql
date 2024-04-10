create or replace procedure crearViaje( 
    m_idRecorrido int, 
    m_idAutocar int, 
    m_fecha date, 
    m_conductor varchar
    ) is
    v_modelo_autocor int;

begin
    --verificar si el recorrido existe o no
    select count(*) into v_modelo_autocor from recorridos where idRecorrido = m_idRecorrido;
    if v_modelo_autocor = 0 then
        raise_application_error(-20001, 'recorridos inexistente');
    end if;

    --verificar si el autocar existe o no
    select count(*) into v_mocdelo_autocor from autocares where idAutocares = m_idAutocares;
    if v_mocdelo_autocor = 0 then
        raise_application_error(-20002, 'autocar_inexistente');
    end if;
end;