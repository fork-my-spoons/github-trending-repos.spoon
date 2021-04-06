local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Chrome Bookmarks"
obj.version = "1.0"
obj.author = "Pavel Makhov"
obj.homepage = "https://github.com/fork-my-spoons/take-a-break.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.indicator = nil
obj.iconPath = hs.spoons.resourcePath("icons")
obj.timer = nil
obj.refreshTimer = nil
obj.notificationType = nil
obj.menu = {}
obj.color_levels = {}
obj.username = ''
obj.task = nil

obj.color_mapping = {
    [4] = '#216e39',
    [3] = '#30a14e',
    [2] = '#40c463',
    [1] = '#9be9a8',
    [0] = '#ebedf0'
}

local star_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})
local fork_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }, color = {hex = '#8e8e8e'}})


local function show_warning(text)
    hs.notify.new(function() end, {
        autoWithdraw = false,
        title = 'GitHub Contributions Spoon',
        informativeText = string.format(text)
    }):send()
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function obj:init()
    self.indicator = hs.menubar.new()

end

function obj:setup(args)
    self.username = args.username
    self.indicator:setTitle(hs.styledtext.new('', { font = {name = 'feather', size = 12 } } ) )

    local week_ago = os.date('%Y-%m-%d' ,os.time() - (7 * 24 * 60 * 60))
    local url = 'https://api.github.com/search/repositories?sort=stars&order=desc&&q=' .. hs.http.encodeForQuery('created:>' .. week_ago)
    hs.http.asyncGet(url, {}, function(status, body)
        local repos = hs.json.decode(body).items

        for _, repo in ipairs(repos) do

            local descr = ''
            if (repo.description ~= nil) then
                for i,v in ipairs(split(repo.description, ' ')) do
                    descr = descr .. ' ' .. v
                    if i % 8 == 0 then descr = descr .. '\n' i = 0 end
                end
                descr = descr .. '\n'
            end

            table.insert(self.menu, {
                image = hs.image.imageFromURL(repo.owner.avatar_url):setSize({w=32,h=32}),
                title = hs.styledtext.new(repo.name .. '\n')
                    .. hs.styledtext.new(descr, {color = {hex = '#8e8e8e'}})
                    .. hs.styledtext.new((repo.language == nil and '' or repo.language .. '   '), {color = {hex = '#8e8e8e'}})
                    .. star_icon .. hs.styledtext.new(repo.stargazers_count .. '   ', {color = {hex = '#8e8e8e'}})
                    .. fork_icon .. hs.styledtext.new(repo.forks_count .. '   ', {color = {hex = '#8e8e8e'}})
                    ,
                fn = function() os.execute('open ' .. repo.html_url) end
            })

            table.insert(self.menu, {title = '-'})
        end
        
        self.indicator:setMenu(self.menu)

    end)
end

function obj:start()
    -- self.task:start()
end

return obj