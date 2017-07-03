#manytoone_Array{Int}
function my_deferred_acceptance(prop_prefs::Array{Int},
                                resp_prefs::Array{Int},
                                caps::Vector{Int})
    prop_size = size(prop_prefs, 2) #prop主体数
    resp_size = size(resp_prefs, 2) #pref主体数
    prop_matched = zeros(Int64, prop_size) #propマッチ相手配列の初期化
    resp_matched = zeros(Int64, sum(caps)) #resfマッチ相手配列の初期化
    next_prop = zeros(Int64, prop_size) #propが次にプロポーズをする時の回数
    max_prop = Int64[] #最大プロポーズ回数配列の初期化
    
    for p in 1:prop_size
        push!(max_prop, find(prop_prefs[:, p] .== 0)[1]-1) #最大プロポーズ回数配列の設定
    end
    
    indptr = Array{Int}(resp_size+1)
    indptr[1] = 1
    for i in 1:resp_size
        indptr[i+1] = indptr[i] + caps[i]
    end
    
    while any(prop_matched .== 0) == true
        prop_single = find(prop_matched .== 0) #マッチしてない学生一覧
        if all(next_prop[prop_single] .>= max_prop[prop_single]) == true #全員が最大プロポーズ回数をこえていればbreak
            break
        else
            for each_prop_single in prop_single
                proposing = prop_prefs[next_prop[each_prop_single]+1, each_prop_single] #次にプロポーズする相手
                if proposing != 0
                    next_prop[each_prop_single] = next_prop[each_prop_single]+1
                    if sum(resp_matched[indptr[proposing]:indptr[proposing+1]-1] .== 0) != 0 && (find(resp_prefs[:, proposing] .==each_prop_single) .<  find(resp_prefs[:, proposing] .==0)) == [true]
                        prop_matched[each_prop_single] = proposing
                        matched_index = findfirst(resp_matched[indptr[proposing]:indptr[proposing+1]-1] .== 0)
                        resp_matched[matched_index + indptr[proposing] - 1] = each_prop_single
                    elseif sum(resp_matched[indptr[proposing]:indptr[proposing+1]-1] .== 0) .== 0 #respに0の枠あり
                        current_order = Int64[]
                        for i in 1:caps[proposing] push!(current_order, find(resp_prefs[:, proposing] .== resp_matched[indptr[proposing]+i-1])[1]) end
                        if all(findmax(current_order)[1] .> find(resp_prefs[:, proposing] .== each_prop_single)) == true
                        prop_matched[each_prop_single] = proposing
                        prop_matched[resp_matched[findmax(current_order)[2] + indptr[proposing] - 1]] = 0
                        resp_matched[findmax(current_order)[2] + indptr[proposing] - 1] = each_prop_single
                        end
                    end
                end
            end
        end
    end
       
    return prop_matched, resp_matched, indptr
end  