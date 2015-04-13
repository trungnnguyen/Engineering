function EnfoqueGlobal(sigma_xx, sigma_yy, sigma_zz, tau_xy, tau_xz, tau_yz, MUESTRAS, CTES)  

    % EnfoqueGlobal(sigma_xx, sigma_yy, sigma_zz, tau_xy, tau_xz, tau_yz, MUESTRAS, CTES)
    % Calcula las tensiones equivalentes de Sines y Crossland. Necesita los
    % valores del tensor de tensiones en cada instante de tiempo, el n�mero
    % de muestras y los datos del material

    % SUPONIENDO QUE LO QUE SE METE ES UN TENSOR QUE PUEDE SEPARARSE EN
    % MEDIA Y ALTERNA

    % CTES

    % Sines
    
    tic
    
    lim_probeta_rotatoria = CTES(1);
    
    sigma_ut = CTES(3);
    
    
    alfa_s = sqrt(2)*(lim_probeta_rotatoria / sigma_ut);
    beta_s = sqrt(2)/3 * lim_probeta_rotatoria;

    % Crossland -> pag 142
    
    lim_tau_torsion = CTES(2);
    
    alfa_c = 3* lim_tau_torsion / lim_probeta_rotatoria - sqrt(3) ; 
    beta_c = lim_tau_torsion ;

    % Inicializar matrices:
    
    tension_princ = zeros(3, MUESTRAS); % matriz cuyas columnas son las tensiones principales en cada instante de tiempo
    
    % MATLAB ORDENA LAS TENSIONES DE MENOR A MAYOR, POR LO QUE EN UN CASO UNIAXIAL
    % UNA TENSI�N EMPIEZA SIENDO SIGMA_3 Y PASA A SER SIGMA_1
    % Y CALCULA MAL LAS TENSIONES MEDIAS Y VARIABLES 
    
    % Para evitarlo:
    
    % Como las tensiones principales no pueden variar para que enfoque
    % global funcione, se calcula para el primer punto la tensiones
    % principales y las direcciones principales y con estos vectores
    % principales se calculan el resto de tensiones principales.
    
    sigma= [sigma_xx(2)  tau_xy(2)  tau_xz(2); tau_xy(2)  sigma_yy(2)  tau_yz(2); tau_xz(2)  tau_yz(2) sigma_zz(2)];
    
    [vectores_princ tens_princ]= eig(sigma);
    
    
    for j=1:MUESTRAS
        
       % calcular tensiones principales       
       
       sigma= [sigma_xx(j)  tau_xy(j)  tau_xz(j); tau_xy(j)  sigma_yy(j)  tau_yz(j); tau_xz(j)  tau_yz(j) sigma_zz(j)];
       
       tens_princ = vectores_princ' * sigma* vectores_princ;
       
       tens_princ = [tens_princ(1,1); tens_princ(2,2); tens_princ(3,3)];
       
       tension_princ(:,j)= tens_princ;
       
    end
    
    
    % Tensiones octaedricas en los instantes de tiempo (vector 1xMUESTRAS)   
    
    
    tau_octaedrica= zeros(1,MUESTRAS);
    
    for j=1: MUESTRAS
        
        tau_octaedrica(j) = 1/3 * ((tension_princ(1,j)-tension_princ(2,j))^2 + (tension_princ(1,j)-tension_princ(3,j))^2 +(tension_princ(2,j)-tension_princ(3,j))^2).^0.5; 

        % CRITERIO DE SIGNOS A TAU_OCTAEDRICA
        
        if (tension_princ(1,j)+ tension_princ(2,j)+ tension_princ(3,j)<0);

           tau_octaedrica(j)= -tau_octaedrica(j);

        end
   
    end
   
    
    % Tensiones hidrostaticas en los instantes de tiempo (vector 1xMUESTRAS)
    sigma_hidrost = (tension_princ(1,:)+ tension_princ(2,:)+ tension_princ(3,:))/3 ; 
    
    
    % Tension hidrostatica media
    
    sigma_hidrost_m = (min(sigma_hidrost) + max(sigma_hidrost))/2;
    
    %Tension octaedrica variable
    
    tau_octaedrica_r = (max(tau_octaedrica)-min(tau_octaedrica)) /2;
    sigma_octaedrica_r = 3*tau_octaedrica_r/sqrt(2);
    j_2_r = sqrt(3/2)*tau_octaedrica_r;  % segundo invariante
    
    
        
    % SINES 
       
    Sines = tau_octaedrica_r + alfa_s * sigma_hidrost_m ; % Para ver si falla o no
    
    Sines2 = sigma_octaedrica_r + 3*lim_probeta_rotatoria*sigma_hidrost_m/sigma_ut ; % M�s c�moda para comparar con VM
 
    
    fprintf('\n Tensi�n equivalente de Sines: \n')
    disp(num2str(Sines))

    if Sines < beta_s

        fprintf('\n No se produce fallo seg�n Sines \n')

    else

        fprintf('\n Se produce fallo seg�n Sines \n')

    end

    % ---------------------------------------------------------------
       
    % CROSSLAND
    
    % sigma_eq_c = tau_octaedrica + alfa_c * sigma_hidrost_maxima > beta_c
    
    Crossland = j_2_r + alfa_c * max(sigma_hidrost); 
    
    fprintf('\n Tensi�n equivalente de Crossland: \n')
    disp(num2str(Crossland'))

    if  Crossland < beta_c

        fprintf('\n No se produce fallo seg�n Crossland \n')

    else 

        fprintf('\n Se produce fallo seg�n Crossland \n')
        
    end
    
    toc
    
end