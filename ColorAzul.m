% Crear un objeto de la cámara
cam = webcam;

% Configurar la vista previa
%preview(cam);
  

while true
    % Capturar un fotograma desde la cámara
    frame = snapshot(cam);

    % Convertir el fotograma al espacio de color HSV
    frame_hsv = rgb2hsv(frame);

    % Definir umbrales para el color amarillo en HSV
    umbral_azul_min = [0.55, 0.4, 0.1];
    umbral_azul_max = [0.7, 1, 1];

    % Crear una máscara para el color amarillo
    mask_azul = (frame_hsv(:,:,1) >= umbral_azul_min(1)) & (frame_hsv(:,:,1) <= umbral_azul_max(1)) & ...
                    (frame_hsv(:,:,2) >= umbral_azul_min(2)) & (frame_hsv(:,:,2) <= umbral_azul_max(2)) & ...
                    (frame_hsv(:,:,3) >= umbral_azul_min(3)) & (frame_hsv(:,:,3) <= umbral_azul_max(3));

    % Aplicar la máscara al fotograma original
    frame_azul = frame;
    frame_azul(repmat(~mask_azul, [1, 1, 3])) = 0;

    frame_azul1=frame_azul(:,:,3);
    frame_azul1=mat2gray(frame_azul1);

    % Aplicar un filtro de mediana para eliminar ruido en frame_amarillo
    frame_azul_suavizado = wiener2(mask_azul,[3 3]);
      % Calcular gradientes con el operador de Sobel
    gradiente_x = edge(frame_azul_suavizado, 'Sobel', 'horizontal');
    gradiente_y = edge(frame_azul_suavizado, 'Sobel', 'vertical');
    
    % Calcular la magnitud del gradiente
    magnitud_gradiente = sqrt(gradiente_x.^2 + gradiente_y.^2);

    % Aplicar umbral para obtener la máscara binaria
    umbral = 0.8; % Ajusta según sea necesario
    mascara_segmentada = magnitud_gradiente > umbral;

    % Aplicar la máscara a la imagen original
    frame_segmentado = frame;
    frame_segmentado(repmat(~mascara_segmentada, [1, 1, 3])) = 20;
    
    %Amplicacion Operador Canny
    bordes_canny = edge(frame_azul1, 'prewitt');
    
    % Aplicar la máscara binaria resultante del operador Canny a la imagen original
    frame_amarillo_segmentado = frame_azul;
    frame_amarillo_segmentado(repmat(~bordes_canny, [1, 1, 3])) = 0;
    
     frame_Bw= mat2gray(frame_azul(:,:,2));
    Iw=bwareaopen(frame_Bw,130);
    se=strel('disk',15,8);
    Iw=imclose(Iw,se);
    frame_mascara=frame;
    frame_mascara(repmat(~Iw, [1, 1, 3])) = 0;
    %II=histeq(Iw);
    II2=histeq(frameHis(:,:,1));
    hold on
%     subplot(1,3,1)
%     imhist(I)
%     title('Resultado');
%     subplot(1,3,3)
%     imhist(II2)
%     title('Entrada');
    %imhist(II)
    %subplot(1,3,2)
    imshowpair(frame_mascara,frame_azul,'montage');
    % Mostrar el fotograma original y la detección de color amarillo
    %imshowpair(frame_segmentado, frame_rojo, 'montage');


    
    % Mostrar el fotograma original y la detección de color amarillo
    %imshowpair(frame_amarillo_segmentado, frame_azul, 'montage');
    title('Fotograma Original vs. Detección de Color Azul');

    pause(0.1);

end
  
% Limpiar después de la ejecución
clear cam;
