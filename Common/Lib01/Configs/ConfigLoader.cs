using Azure.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;

namespace Lib01.Configs
{
    public class ConfigLoader
    {
        public static void LoadConfiguration(IConfigurationBuilder configBuilder)
        {
            configBuilder.AddJsonFile(Environment.GetEnvironmentVariable("CH_DEMO_CONFIG"));

            var config = configBuilder.Build();

            // Retrieve the connection string
            string appConfigConnection = config.GetValue<string>("AppConfig");
            string appConfigLabel = config.GetValue<string>("AppConfigLabel");
            string kvclientId = config.GetValue<string>("KVClientId");
            string kvclientSecret = config.GetValue<string>("KVClientSecret");
            string tenantId = config.GetValue<string>("AzureAdTenantId");
            string resourceGroupName = config.GetValue<string>("WEBSITE_RESOURCE_GROUP");

            //Load configuration from Azure App Configuration
            configBuilder.AddAzureAppConfiguration(options =>
                            options
                                .Connect(appConfigConnection)
                                .Select(KeyFilter.Any, resourceGroupName) // Shared configs
                                .Select(KeyFilter.Any, appConfigLabel) // Blue or green configs
                                .ConfigureKeyVault(kv =>
                                {
                                    kv.SetCredential(string.IsNullOrEmpty(kvclientId) || string.IsNullOrEmpty(kvclientSecret) || string.IsNullOrEmpty(tenantId)
                                        ? new DefaultAzureCredential() : new ClientSecretCredential(tenantId, kvclientId, kvclientSecret));
                                })
                        );


            configBuilder.Build();
        }
    }
}
