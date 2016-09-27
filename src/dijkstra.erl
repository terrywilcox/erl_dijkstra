-module(dijkstra).

-export([find_path/3]).

-include_lib("eunit/include/eunit.hrl").

find_path(Start, Destination, Edges) ->
  find_path([{0, [Start]}], Destination, Edges, maps:keys(Edges)).

find_path([{Cost, [Destination|_] = Shortest}|_], Destination, _, _) ->
  {Cost, lists:reverse(Shortest)};
find_path([], _, _, _) ->
  no_path;
find_path(_, _, _, []) ->
  no_path;
find_path([{_, [CurrentNode|_]} = CurrentPath|_] = Paths, Destination, Edges, Unvisited) ->
  NowUnvisited = lists:delete(CurrentNode, Unvisited),
  PathsToUnvisitedNodes = remove_paths_to_node(CurrentNode, Paths),
  PathsToUnvisitedNeighbors = paths_to_unvisited_neighbors(CurrentPath, Edges, NowUnvisited),
  find_path(lists:sort(PathsToUnvisitedNeighbors ++ PathsToUnvisitedNodes), Destination, Edges, NowUnvisited).

remove_paths_to_node(Node, Paths) ->
  lists:filter(fun({_, [N|_]}) -> N =/= Node  end, Paths).

paths_to_unvisited_neighbors({Cost, [Current|_] = Path}, Edges, Unvisited) ->
  lists:map(fun({N, C}) -> {C + Cost, [N | Path]} end, unvisited_neighbors(Current, Edges, Unvisited)).

unvisited_neighbors(Current, Edges, Unvisited) ->
  lists:filter(fun({X, _}) -> lists:member(X, Unvisited) end, maps:get(Current, Edges)).

%%% tests

edges() ->
   #{
    a => [{b, 3}, {d, 5}, {e, 4}],
    b => [{c, 6}],
    c => [{f, 1}, {h, 7}],
    d => [{c, 1}, {f, 3}, {g, 2}],
    e => [{g, 5}],
    f => [{h, 2}],
    g => [{f, 1}, {h, 3}],
    h => []
  }.

find_path_test_() ->
  [
    {"a to a", ?_assertEqual({0, [a]}, find_path(a, a, edges()))},
    {"a to c", ?_assertEqual({6, [a, d, c]}, find_path(a, c, edges()))},
    {"d to h", ?_assertEqual({4, [d, c, f, h]}, find_path(d, h, edges()))},
    {"a to h", ?_assertEqual({9, [a, d, c, f, h]}, find_path(a, h, edges()))},
    {"no path", ?_assertEqual(no_path, find_path(b, a, edges()))}
  ].
