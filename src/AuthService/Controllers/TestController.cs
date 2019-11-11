using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Polly;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace AuthService.Controllers
{
    public class TestController : Controller
    {
        // GET: /<controller>/
        public IActionResult Index()
        {
            string content = "111";
            ISyncPolicy policy = Policy.Handle<Exception>()
            .Fallback(() =>
            {
                content = "333";
                Console.WriteLine("Error occured");
            });

            policy.Execute(() =>
            {
                content = "222";
                throw new Exception("出错了");
                Console.WriteLine("Job End");
            });

            return Content(content);
        }
    }
}
