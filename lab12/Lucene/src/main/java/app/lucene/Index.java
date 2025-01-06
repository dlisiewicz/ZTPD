package app.lucene;

import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;

public class Index {
    private static final String INDEX_DIRECTORY = "lucene_index";

    public static void main(String[] args) throws IOException {
        StandardAnalyzer analyzer = new StandardAnalyzer();
        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));
        IndexWriterConfig config = new IndexWriterConfig(analyzer);

        try (IndexWriter w = new IndexWriter(directory, config)) {
            w.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
            w.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
            w.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
            w.addDocument(buildDoc("Naturalnie urodzeni mordercy", "9780316485616"));
            w.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
            w.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));
            System.out.println("Indexing completed!");
        }
    }

    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }
}
