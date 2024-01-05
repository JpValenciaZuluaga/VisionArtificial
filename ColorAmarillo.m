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
    umbral_amarillo_min = [0.1, 0.5, 0.4];
    umbral_amarillo_max = [0.2, 1, 1];

    % Crear una máscara para el color amarillo
    mask_amarillo = (frame_hsv(:,:,1) >= umbral_amarillo_min(1)) & (frame_hsv(:,:,1) <= umbral_amarillo_max(1)) & ...
                    (frame_hsv(:,:,2) >= umbral_amarillo_min(2)) & (frame_hsv(:,:,2) <= umbral_amarillo_max(2)) & ...
                    (frame_hsv(:,:,3) >= umbral_amarillo_min(3)) & (frame_hsv(:,:,3) <= umbral_amarillo_max(3));

    % Aplicar la máscara al fotograma original
    frame_amarillo = frame;
    frame_amarillo(repmat(~mask_amarillo, [1, 1, 3])) = 0;

     

    frame_amarillo1=frame_amarillo(:,:,3);
    frame_amarillo1=mat2gray(frame_amarillo1);
    
    % Aplicar un filtro de mediana para eliminar ruido en frame_amarillo
    frame_amarillo_suavizado = wiener2(mask_amarillo,[3 3]);
    
    frame_re=mat2gray(frame_amarillo_suavizado);
      % Calcular gradientes con el operador de Sobel
    gradiente_x = edge(frame_amarillo_suavizado, 'Sobel', 'horizontal');
    gradiente_y = edge(frame_amarillo_suavizado, 'Sobel', 'vertical');
    
    % Calcular la magnitud del gradiente
    magnitud_gradiente = sqrt(gradiente_x.^2 + gradiente_y.^2);

    % Aplicar umbral para obtener la máscara binaria
    umbral = 0.8; % Ajusta según sea necesario
    mascara_segmentada = magnitud_gradiente > umbral;

    % Aplicar la máscara a la imagen original
    frame_segmentado = frame;
    frame_segmentado(repmat(~magnitud_gradiente, [1, 1, 3])) = 0;
    frame_segmentado=bwareaopen(frame_segmentado,200);
    %Amplicacion Operador Canny
    bordes_canny = edge(mascara_segmentada, 'prewitt');
    frameHis=mat2gray(frame);
    
    % Aplicar la máscara binaria resultante del operador Canny a la imagen original
    frame_amarillo_segmentado = frame_amarillo;
    frame_amarillo_segmentado(repmat(~bordes_canny, [1, 1, 3])) = 0;
    %relleno
      %frame_amarillo=imbinarize(frame_amarillo);
    frame_Bw= mat2gray(frame_amarillo(:,:,2));
    Iw=bwareaopen(frame_Bw,130);
    se=strel('disk',15,8);
    Iw=imclose(Iw,se);
    frame_mascara=frame;
    frame_mascara(repmat(~Iw, [1, 1, 3])) = 0;
%     %II=histeq(Iw);
%     II2=histeq(frameHis(:,:,1));
%     hold on
%     
%     title('Resultado');
%     subplot(1,2,3)
%     imhist(frame_amarillo_segmentado)
%     title('Entrada');
%     %imhist(II)
%     subplot(1,2,2)
%     imshow(frame_mascara);

    % Mostrar el fotograma original y la detección de color amarillo
    imshowpair(frame_mascara, frame_amarillo, 'montage');
    title('Fotograma Original vs. Detección de Color Amarillo');
    hold off
    pause(0.1);

end
  
% Limpiar después de la ejecución
clear cam;
