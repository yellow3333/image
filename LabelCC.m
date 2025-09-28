function [] = LabelCC(binary_image)
    % binary_image = randi(2,5,5) - ones(5)
    % binary_image = randi(2,5,5) - ones(5)

    image_size = size(binary_image);
    disp(binary_image);
    [label_image, label_array] = four_connected(binary_image, image_size);
    [label_image, label_array] = shoew_image(label_image, label_array, image_size);

    [label_image, label_array] = eight_connected(binary_image, image_size);
    [label_image, label_array] = shoew_image(label_image, label_array, image_size);

    return
end

function [label_array] = min_label_array(label_array, max_index, min_index)
    while(max_index > min_index)
        tmp = label_array(max_index);
        label_array(max_index) = min_index;
        max_index = tmp;
    end
    return
end

function [label_image,label_array] = reorder_label_array(label_image,label_array,index_i,index_j,index_y2,index_x2)
        max_index = max(label_image(index_i,index_j),label_image(index_y2,index_x2));
        min_index = min(label_image(index_i,index_j),label_image(index_y2,index_x2));
        while(min_index ~= label_array(min_index))
            min_index = label_array(min_index);
        end
        label_image(index_i,index_j) = min_index;
        label_array = min_label_array(label_array,max_index,min_index);
    return
end

function x = check_around_label_eight(label_image, i, j, image_size)
    x = 0;
    if( j == 1)
        x = label_image(i-1,j+1);
        return
    elseif( j == image_size(2) )
        x = label_image(i-1,j-1);
        return
    end
    
    topRight = label_image(i-1, j+1);
    topLeft = label_image(i-1, j-1);
    if(topRight ~= topLeft)
        if(topRight ~= 0 && topLeft ~= 0)
            x = -1; % conflict
        else
            x = max(topRight, topLeft);
        end
    else
        x = topLeft;
    end

    return
end 

function [label_image, label_array] = eight_connected(binary_image, image_size)
    [label_image, label_array] = four_connected(binary_image, image_size);
    for i=2:image_size(1)
        for j=1:image_size(2)
            if(label_image(i,j) ~= 0)
                mark = check_around_label_eight(label_image, i, j, image_size);
                if(mark ~= 0)
                    if(mark == -1)
                        [label_image, label_array] = reorder_label_array(label_image, label_array , i, j, i-1,j-1);
                        [label_image, label_array] = reorder_label_array(label_image, label_array , i, j, i-1,j+1);
                    else 
                        max_index = max(mark,label_image(i,j));
                        min_index = min(mark,label_image(i,j));
                        label_image(i,j) = min_index;
                        label_array = min_label_array(label_array,max_index,min_index);
                    end
                end
            end
        end
    end
    return 
end

function [label_image, label_array] = four_connected(binary_image, image_size)
    label = 1;
    label_array = linspace(0,0,image_size(1)/2*image_size(2));
    label_image = zeros(image_size);
    for i=1:image_size(1)
        for j=1:image_size(2)
            if(binary_image(i,j) == 1)
                mark = check_around_label_four(label_image, i, j);
                if(mark == 0)
                    mark = label;
                    label_array(mark) = mark;
                    label = label + 1;
                elseif(mark == -1)
                    [label_image, label_array] = reorder_label_array(label_image, label_array , i-1, j, i,j-1);
                    mark = label_image(i-1,j);
                end
                label_image(i,j) = mark;
            end
        end
    end

    
    
    return
end

function [label_image, new_label_array] = shoew_image(label_image, label_array, image_size)
    new_label_array = label_array;
    label = 0;
    for i = 1:image_size(1)/2*image_size(2)
        if(label_array(i) == i)
            label = label + 1;
            new_label_array(i) = label;
            new_label_array(label) = label;
        end
    end 
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            if(label_image(i,j) ~= 0)
                label_image(i,j) = new_label_array(label_array(label_image(i,j)));
            end
        end
    end
    
    disp(label_image)

    % I = mat2gray(label_image*100,[label*100, 0]);
    % figure, imshow(I);
    % title("component")
    return
end

function x = check_edge_top_left_label(label_image, i, j)
    x = 0;
    if(i==1 && j==1)
        return
    elseif(i==1)
        x = label_image(i,j-1);
    elseif(j==1)
        x = label_image(i-1,j);
    end
    return 
end

function x = check_around_label_four(label_image, i, j)
    x = 0;
    if(i==1 || j==1)
        x = check_edge_top_left_label(label_image, i, j);
        return
    end
    
    top = label_image(i-1, j);
    left = label_image(i, j-1);
    if(top ~= left)
        if(top ~= 0 && left ~= 0)
            x = -1; % conflict
        else
            x = max(top, left);
        end
    else
        x = left;
    end

    return
end
