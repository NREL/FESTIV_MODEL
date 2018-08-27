function opt_struct = festivSetDefault(opt_struct, fieldname, default)
% FESTIVSETOUTPUT Simple function to add a default to an option structure
%
% Usage: opt = festivSetDefault(opt, 'option', default);
%
% If opt doesn't have a member fieldname, one is added. And if added or blank
% its value is set to the default
if not(isfield(opt_struct, fieldname))
        opt_struct.(fieldname) = default;
end
