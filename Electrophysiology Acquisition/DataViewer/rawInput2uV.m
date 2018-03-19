function data = rawInput2uV(data,gain)


% For conversion to microvolts
data = data./gain.*1E6;