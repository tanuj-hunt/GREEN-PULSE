using System.Web.Http;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.AspNet.SignalR;

namespace Energy
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            // Register Web API routes
            GlobalConfiguration.Configure(WebApiConfig.Register);

            // Register MVC routes (if used)
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Ensure all configurations are initialized
            GlobalConfiguration.Configuration.EnsureInitialized();
        }
    }
}
