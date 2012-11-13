function [varargout] = reshape_batch1(dims, varargin)

    for k = 1 : numel(varargin)
        varargout{k} = reshape(varargin{k}, dims);
    end
