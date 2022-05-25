# 思路APP API开发文档

# get_user_info
- 获取指定用户的个人信息
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|target_user_id|int|目标用户ID|
|login_user_id|int|登录用户ID|

## 响应信息
- status
- user_info
    - |参数名|类型|说明|
      |:-:|:-:|-|
      |id|int|目标用户ID|
      |username|string|用户名|
      |phone_number|string|手机号|
      |user_type|int|用户类型|
      |introduction|string|个人简介|
      |icon_key|string|头像key|
      |follow_status|bool|登录用户对目标用户的关注状态|

# get_address_list
- 获取指定用户的地址列表
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|目标用户ID|

## 响应信息
- status
- address_list
    - |参数名|类型|说明|
      |:-:|:-:|-|
      |id|int|地址ID|
      |address_name|string|地址名称|
      |latitude|double|纬度|
      |longitude|double|经度|

# edit_address
- 编辑指定用户的地址信息
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|目标用户ID|
|action|int|0：添加<br>1：修改<br>2：删除|
|address_id|int|地址ID，修改和删除时必须提供|
|address_name|string|地址名称，添加和修改时必须提供|
|latitude|double|纬度，添加和修改时必须提供|
|longitude|double|经度，添加和修改时必须提供|

## 响应信息
- status

# mark_activity
- 标记指定动态
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|登录用户ID|
|activity_id|int|动态ID|
|mark_type|int|0：访问<br>1：点赞<br>2：收藏|
|action|int|动作，点赞和收藏时必须提供<br>0：执行动作<br>1：取消动作|

## 响应信息
- status

# get_activity_info
- 获取指定动态的详细信息
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|login_user_id|int|登录用户ID|
|activity_id|int|动态ID|

## 响应信息
- status
- activity_info
    - |参数名|类型|说明|
      |:-:|:-:|-|
      |love_status|bool|登录用户对该动态的点赞状态|
      |love_count|int|该动态的被点赞数量|
      |collection_status|bool|登录用户对该动态的收藏状态|
      |collection_count|int|该动态的被收藏数量|
      |visit_count|int|该动态的被访问数量|

# get_activity_list
- 获取一批动态
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|offset|int|获取batch的偏移量|
|limit|int|获取的batch size|
|login_user_id|int|登录用户ID|
|search_type|int|获取的动态类型<br>0：获取最新动态<br>1：获取目标用户的最新动态<br>2：获取登录用户所关注的用户动态<br>3：获取目标用户点赞过的动态<br>4：获取目标用户收藏过的动态<br>5：获取登录用户访问过的动态|
|search_user_id|int|目标用户ID，当search_type为1,3,4时必须指定|

## 响应信息
- status
- activity_list
    - |参数名|类型|说明|
      |:-:|:-:|-|
      |id|int|动态ID|
      |author_id|int|作者ID|
      |num|int|该动态在batch中的位置（该字段后续可以去掉）|
      |title|string|动态标题|
      |content|string|动态内容|
      |activity_type|int|动态类型|
      |create_time|string|创建时间|
      |last_edit_time|string|修改时间|
      |love_status|bool|登录用户对该动态的点赞状态|
      |love_count|int|该动态的被点赞数量|
      |collection_status|bool|登录用户对该动态的收藏状态|
      |collection_count|int|该动态的被收藏数量|
      |visit_count|int|该动态的被访问数量|
      |images_info|list|图片列表<br>key, string<br>width, int<br>height, int|
      |latitude|double|纬度，添加和修改时必须提供|
      |longitude|double|经度，添加和修改时必须提供|
      |description|string|描述|
      |access_time|string|动态生效时间|
      
# upload_activity
- 上传动态
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|登录用户ID|
|title|string|动态标题|
|context|string|动态内容|
|oss_img_list|list|图片列表<br>key, string<br>width, int<br>height, int|
|location|map|latitude, double, 纬度<br>longitude, double, 经度<br>address, string, 地点名称<br>|
|activity_type|int|动态类型|
|access_time|string|动态生效时间|

## 响应信息
- status

# edit_user_info
- 修改用户信息
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|登录用户ID|
|new_username|string|用户名|
|new_introduction|string|个人简介|
|new_icon_key|string|头像key|

## 响应信息
- status

# follow
- 登录用户关注/取消对目标用户的关注
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|fan_id|int|登录用户ID|
|followed_user_id|int|目标用户ID|
|action|int|0：执行动作<br>1：取消动作|

## 响应信息
- status
      
# get_follow_list
- 获取目标用户的关注和粉丝列表
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|login_user_id|int|登录用户ID|
|target_user_id|int|目标用户ID|
|search_type|int|查询类型<br>0：查询目标用户的粉丝列表<br>1：查询目标用户的关注列表|

## 响应信息
- status
- user_info_list
    - |参数名|类型|说明|
      |:-:|:-:|-|
      |id|int|目标用户ID|
      |username|string|用户名|
      |phone_number|string|手机号|
      |user_type|int|用户类型|
      |introduction|string|个人简介|
      |icon_key|string|头像key|
      |follow_status|bool|登录用户对于该用户的关注状态|

# delete_activity_admin
- 删除动态
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|activity_id|int|动态ID|

## 响应信息
- status

# login_phone_step1
- 获取验证码
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|phone_number|string|手机号|

## 响应信息
- status

# login_phone_step2
- 检查验证码是否正确
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|phone_number|string|手机号|
|validate_code|string|验证码|

## 响应信息
|参数名|类型|说明|
|:-:|:-:|-|
|status|bool|状态|
|user_id|int|登录用户ID|

# upload_comment
- 对指定动态进行评论（后端自动记录评论时间）
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|user_id|int|登录用户ID|
|activity_id|int|动态ID|
|father_comment_id|int|评论ID，对评论进行评论时使用<br>-1表示对动态进行评论|
|content|string|评论内容|

## 响应信息
|参数名|类型|说明|
|:-:|:-:|-|
|status|bool|状态|

# get_comment_by_activity_id
- 获取目标动态的所有评论
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|offset|int|获取batch的偏移量|
|limit|int|获取的batch size|
|activity_id|int|动态ID|

## 响应信息
- status
- comment_list
  - |参数名|类型|说明|
    |:-:|:-:|-|
    |id|int|评论ID|
    |author_id|int|评论发布者ID|
    |content|string|评论内容|
    |create_time|string|评论时间|
    |sub_comments|list|子评论列表|

# delete_comment
- 删除指定评论
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|comment_id|int|评论ID|

## 响应信息
|参数名|类型|说明|
|:-:|:-:|-|
|status|bool|状态|

# send_message
- 给目标用户发送私信
- 后端自动记录消息时间
- 后端需将该私信状态标记为未获取

## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|from_user_id|int|登录用户ID|
|to_user_id|int|目标用户ID|
|content|string|消息内容|

## 响应信息
|参数名|类型|说明|
|:-:|:-:|-|
|status|bool|状态|

# get_new_message_list
- 获取新私信列表
- 后端执行后需将所有未获取私信的状态标记为已获取
## 请求信息
|参数名|类型|说明|
|:-:|:-:|-|
|login_user_id|int|登录用户ID|

## 响应信息
- status
- message_list
  - |参数名|类型|说明|
    |:-:|:-:|-|
    |author_id|int|消息发送者ID|
    |content|string|消息内容|
    |time|string|消息发送时间|
