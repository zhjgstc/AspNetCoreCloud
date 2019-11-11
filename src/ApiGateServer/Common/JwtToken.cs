using System;
using System.Collections.Generic;
using JWT;
using JWT.Algorithms;
using JWT.Serializers;
using Newtonsoft.Json;

namespace ApiGateServer.Common
{
    public class JwtToken
    {
        /// <summary>
        /// 返回一个加密字符串
        /// </summary>
        /// <param name="secret">密钥</param>
        /// <returns></returns>
        public string EncodeToken(string secret)
        {
            Result result = new Result() { Code = 0,Data=DateTime.Now.ToLongTimeString()};

            //var payload = new Dictionary<string, object>
            //{
            //    { "Code", 0 },
            //    { "claim2", "claim2-value" }
            //};

            IJwtAlgorithm algorithm = new HMACSHA256Algorithm();
            IJsonSerializer serializer = new JsonNetSerializer();
            IBase64UrlEncoder urlEncoder = new JwtBase64UrlEncoder();
            IJwtEncoder encoder = new JwtEncoder(algorithm, serializer, urlEncoder);

            var token = encoder.Encode(result, secret);
            return token;
        }

        /// <summary>
        /// 将字符串token解密
        /// </summary>
        /// <param name="token">加密字符串</param>
        /// <returns></returns>
        public Result DecodeToken(string secret,string token)
        {
            try
            {
                IJsonSerializer serializer = new JsonNetSerializer();
                IDateTimeProvider provider = new UtcDateTimeProvider();
                IJwtValidator validator = new JwtValidator(serializer, provider);
                IBase64UrlEncoder urlEncoder = new JwtBase64UrlEncoder();
                IJwtDecoder decoder = new JwtDecoder(serializer, validator, urlEncoder);

                var json = decoder.Decode(token, secret, verify: true);
                return JsonConvert.DeserializeObject<Result>(json);
            }
            catch (TokenExpiredException)
            {
                Console.WriteLine("token已经过期");
                return new Result() { Code = 401, Msg = "密钥过期" };
            }
            catch (SignatureVerificationException)
            {
                Console.WriteLine("token不正确");
                return new Result() { Code = 401, Msg = "错误的字符串" };
            }
            catch (JsonException)
            {
                return new Result() { Code = 401, Msg = "转化json失败" };
            }
        }
    }
}