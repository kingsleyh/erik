import docs4d;

void main()
{

    auto cards = [Card("new", "Yeeha", "void", [], [], [])];

    auto links = [
        //         Link("Home","home.html"),
        Link("Documentation", "#", "active"),
        Link("Github", "https://github.com/kingsleyh/erik")
    ];

    new DocGen("Erik", "v0.0.1", "https://github.com/kingsleyh/erik/blob/master")
    .withLinks(links)
    .withCards(cards)
//    .withPages(pages)
    .generate();

}
