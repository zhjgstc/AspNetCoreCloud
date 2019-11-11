using System;
namespace ApiGateServer.Common
{

    /// <summary>
    /// 统一的返回
    /// </summary>
    public class Result
    {
        public int Code { get; set; }
        public object Data { get; set; }
        public string Msg { get; set; }
        public object Other { get; set; }
    }
}
