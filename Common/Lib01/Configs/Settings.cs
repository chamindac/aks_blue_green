namespace Lib01.Configs
{
    public class Settings
    {
        // Settings from CH_DEMO_CONFIG
        public string? AppConfig { get; set; }
        public string? AppConfigLabel { get; set; }
        public string? KVClientId { get; set; }
        public string? KVClientSecret { get; set; }
        public string? AzureAdTenantId { get; set; }

        // App config settings
        public string? AzureWebJobsStorage { get; set; }
        public string? DemoCustomer { get; set; }
        public string? DemoInvoice { get; set; }
        public string? DemoOrder { get; set; }
        public string? DemoPayment { get; set; }
        public string? EventHubConsumer1 { get; set; }
        public string? EventHubConsumer2 { get; set; }
        public string? EventHubPublisher1 { get; set; }
        public string? EventHubPublisher2 { get; set; }
        public string? SqlDBConnection { get; set; }
    }
}
