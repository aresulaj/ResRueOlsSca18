function cmap = getCmapValues(map,n_values)
%
%
%
%
%

% Created: SRO - 6/19/12





switch map
    case 'jet'
        cmap = colormap(jet(n_values));
    case 'hsv'
        cmap = colormap(hsv(n_values));
    case 'hot'
        cmap = colormap(hot(n_values));
    case 'gray'
        cmap = colormap(gray(n_values));
end

colormap('gray')
