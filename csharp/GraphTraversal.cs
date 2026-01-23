using AwesomeAssertions;

namespace Host.UnitTests;

public class Item
{
    public string Id { get; set; }
    public string[]? RelatedItems { get; set; }
}

public static class GraphTraversal
{
    public static (TItem? root, IEnumerable<TItem>? related) GetItemAndRelated<TKey, TItem>(
        TKey rootId,
        Func<TItem, TKey> idSelector,
        Func<TItem, TKey[]?> relatedIdSelector,
        Func<TKey, TItem?> itemFetcher)
        where TKey : IEquatable<TKey>
        where TItem : notnull
    {
        var rootItem = itemFetcher(rootId);
        if (rootItem == null)
        {
            return (default, null);
        }

        var result = new List<TItem>();
        var visited = new HashSet<TKey>();
        var queue = new Queue<TItem>();

        queue.Enqueue(rootItem);
        visited.Add(idSelector(rootItem));

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (!idSelector(current).Equals(idSelector(rootItem)))
            {
                result.Add(current);
            }

            var relatedItems = relatedIdSelector(current);

            if (relatedItems == null)
            {
                continue;
            }

            foreach (var relatedId in relatedItems)
            {
                if (visited.Contains(relatedId))
                {
                    continue;
                }

                var relatedItem = itemFetcher(relatedId);
                if (relatedItem != null)
                {
                    visited.Add(relatedId);
                    queue.Enqueue(relatedItem);
                }
            }
        }

        return (rootItem, result);
    }
}

public class ItemStore
{
    private readonly Dictionary<string, Item> items = new();

    public (Item? root, IEnumerable<Item>? related) Get(
        string id,
        bool includeRelated = false)
    {
        if (!includeRelated)
        {
            var item = items.GetValueOrDefault(id);
            return (item, null);
        }

        return GraphTraversal.GetItemAndRelated(
            id,
            item => item.Id,
            item => item.RelatedItems,
            key => items.GetValueOrDefault(key));
    }

    public void Add(Item item)
    {
        items.Add(item.Id, item);
    }
}

public class CanRetrieveRelatedItems
{
    [Fact]
    public void can_get_root_item()
    {
        var store = new ItemStore();
        store.Add(new Item { Id = "123" });

        var (root, _) = store.Get("123");
        root.Should().NotBeNull();
    }

    [Fact]
    public void can_get_related_items()
    {
        // arrange
        var store = new ItemStore();
        store.Add(new Item { Id = "123", RelatedItems = ["456", "789"] });
        store.Add(new Item { Id = "456", RelatedItems = ["123"] });
        store.Add(new Item { Id = "789", RelatedItems = ["123", "XXX"] });

        // act
        var (root, related) = store.Get("123", true);

        // assert
        root.Should().NotBeNull();
        related.Should().NotBeNull();
        related.Should().HaveCount(2);

        string[] relatedKeys = ["456", "789"];
        related.Select(x => x.Id).Should().BeEquivalentTo(relatedKeys);
    }
}
