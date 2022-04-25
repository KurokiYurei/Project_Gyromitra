using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WindCurrent : MonoBehaviour
{
    // Start is called before the first frame update
    public float m_pushPower;
    public float m_pushDuration;
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Debug.DrawRay(transform.position, -transform.forward, Color.red, 5f);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            other.GetComponent<CharacterControllerScript>().SetBounceParameters
                (transform.forward, m_pushPower, m_pushDuration);
        }
    }
}