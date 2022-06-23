using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UI_Element : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, ISelectHandler
{
    [SerializeField]
    private Image m_image;

    private bool m_active;

    [SerializeField]
    private GameManagerScript m_gameManager;

    GameObject currentSelected;

    bool m_soundPlayed;

    private void Update()
    {
        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
        }

        if (m_active)
        {
            m_image.gameObject.SetActive(true);
        }
        else
        {
            m_image.gameObject.SetActive(false);
        }

        currentSelected = EventSystem.current.currentSelectedGameObject;

        if (currentSelected == gameObject)
        {
            m_active = true;
            if (!m_soundPlayed)
                m_gameManager.OnHoverPlaySound();
            m_soundPlayed = true;
            print(currentSelected.name);
        }
        else
        {
            m_active = false;
            m_soundPlayed = false;
        }
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        EventSystem.current.SetSelectedGameObject(gameObject);
        m_active = true;
        m_gameManager.OnHoverPlaySound();
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        m_active = false;
    }

    public void OnSelect(BaseEventData eventData)
    {
        m_active = false;
    }
}
