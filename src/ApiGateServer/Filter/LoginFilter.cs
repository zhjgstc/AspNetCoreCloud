using System;
using System.Linq;
using ApiGateServer.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace ApiGateServer.Filter
{
    /// <summary>
    /// 登录验证
    /// </summary>
    public class LoginFilter
    {
        /// <summary>
        /// 判断是否需要登录
        /// </summary>
        /// <param name="context"></param>
        /// <param name="configuration"></param>
        /// <param name="json"></param>
        /// <returns></returns>
        public bool NeedLogin(HttpContext context, IConfiguration configuration,out string json)
        {
            JwtToken jwtToken = new JwtToken();
            var request = context.Request;
            var secret = configuration["jwt.secret"];
            var urls = configuration["user.auth.urls"];

            var items = JsonConvert.DeserializeObject<string[]>(urls);

            json = "";
            if (items.Any(w => request.Path.Value.Contains(w)))
            {
                if (string.IsNullOrEmpty(request.Headers["token"]))
                {
                    var token = jwtToken.EncodeToken(secret);
                    Result result = new Result() { Code=1,Data=token};
                    json =JsonConvert.SerializeObject(result);
                    return false;
                }

                var tokenResult = jwtToken.DecodeToken(secret, request.Headers["token"]);
                if (tokenResult.Code != 0)
                {
                    json = JsonConvert.SerializeObject(tokenResult);
                    return false;
                }
            }
            return true;
        }
    }
}
